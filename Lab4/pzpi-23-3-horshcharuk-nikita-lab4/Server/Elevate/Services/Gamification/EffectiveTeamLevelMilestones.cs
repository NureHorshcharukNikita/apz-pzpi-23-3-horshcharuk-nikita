using Elevate.Entities;

namespace Elevate.Services.Gamification;

public static class EffectiveTeamLevelMilestones
{
    public const double DefaultCurveK = 2.0;

    public readonly record struct Milestone(int OrderIndex, int CumulativePoints, string? AnchorName);

    public static IReadOnlyList<Milestone> Build(
        IReadOnlyList<TeamLevel> rawLevels,
        double curveK = DefaultCurveK)
    {
        if (rawLevels.Count == 0)
            return Array.Empty<Milestone>();

        var merged = rawLevels
            .GroupBy(l => l.OrderIndex)
            .Select(g => g.OrderByDescending(x => x.RequiredPoints).First())
            .OrderBy(l => l.OrderIndex)
            .ToList();

        var maxOrder = merged.Max(l => l.OrderIndex);
        if (maxOrder < 1)
            return Array.Empty<Milestone>();

        var anchorPoints = merged.ToDictionary(l => l.OrderIndex, l => Math.Max(0, l.RequiredPoints));
        var anchorNames = merged.ToDictionary(
            l => l.OrderIndex,
            l => string.IsNullOrWhiteSpace(l.Name) ? null : l.Name);

        var anchorOrders = merged.Select(l => l.OrderIndex).OrderBy(o => o).ToList();

        var lastP = 0;
        foreach (var o in anchorOrders)
        {
            var p = anchorPoints[o];
            if (p < lastP)
                anchorPoints[o] = lastP;
            lastP = anchorPoints[o];
        }

        var result = new List<Milestone>();
        var prevO = 0;
        var prevP = 0;

        foreach (var nextO in anchorOrders)
        {
            var nextP = anchorPoints[nextO];

            if (nextO > prevO + 1)
            {
                for (var o = prevO + 1; o < nextO; o++)
                {
                    var t = (o - prevO) / (double)(nextO - prevO);
                    var raw = prevP + (nextP - prevP) * ExponentialInterp(t, curveK);
                    var c = (int)Math.Round(raw);
                    if (result.Count > 0)
                        c = Math.Max(c, result[^1].CumulativePoints + 1);
                    if (c >= nextP)
                        c = Math.Max(prevP + 1, nextP - 1);
                    result.Add(new Milestone(o, c, null));
                }
            }

            if (nextP <= prevP)
                nextP = (result.Count > 0 ? result[^1].CumulativePoints : prevP) + 1;

            result.Add(new Milestone(nextO, nextP, anchorNames[nextO]));
            prevO = nextO;
            prevP = nextP;
        }

        return result;
    }

    public static double ExponentialInterp(double t, double k)
    {
        t = Math.Clamp(t, 0, 1);
        if (Math.Abs(k) < 1e-9)
            return t;
        return (Math.Exp(k * t) - 1) / (Math.Exp(k) - 1);
    }
}
