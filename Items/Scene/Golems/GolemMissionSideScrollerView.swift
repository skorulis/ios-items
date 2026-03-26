import SwiftUI

@MainActor
struct GolemMissionSideScrollerView: View {
    let enemies: [GolemMissionSlot.Enemy]

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: false)) { context in
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.35), lineWidth: 1)
                        )

                    GeometryReader { geometry in
                        let width = max(geometry.size.width, 1)
                        let laneY = geometry.size.height * 0.72
                        let golemX = width * 0.22
                        let contactX = width * 0.55
                        let isFighting = enemies.contains { enemy in
                            enemy.distanceToGolemMeters <= GolemMissionSlot.enemyAttackRangeMeters
                        }

                        lanePath(y: laneY, width: width)
                            .stroke(Color.gray.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [7, 6]))

                        let t = context.date.timeIntervalSinceReferenceDate
                        let bob = isFighting ? 0 : sin(t * 6) * 1.8

                        golemShape(isWalking: !isFighting)
                            .fill(Color.accentColor)
                            .frame(width: 28, height: 36)
                            .offset(x: golemX, y: laneY - 36 + bob)

                        ForEach(
                            Array(enemies.prefix(GolemMissionSlot.maxEnemies)).enumerated(),
                            id: \.element.id
                        ) { idx, enemy in
                            let enemyX = enemyXPosition(
                                distanceToGolemMeters: enemy.distanceToGolemMeters,
                                laneWidth: width,
                                contactX: contactX
                            )
                            let yOffset = CGFloat(idx) * 4
                            enemyShape(for: enemy.type)
                                .foregroundStyle(enemyColor(for: enemy.type))
                                .frame(width: 28, height: 30)
                                .offset(x: enemyX, y: laneY - 30 + yOffset)
                        }
                    }
                }
                .frame(height: 112)

                if !enemies.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(enemies.prefix(GolemMissionSlot.maxEnemies)) { enemy in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(enemyColor(for: enemy.type))
                                    .frame(width: 8, height: 8)
                                ProgressView(value: enemy.remainingFraction)
                                    .tint(enemyColor(for: enemy.type))
                            }
                        }
                    }
                }
            }
        }
    }

    private func lanePath(y: CGFloat, width: CGFloat) -> Path {
        Path { path in
            path.move(to: CGPoint(x: 8, y: y))
            path.addLine(to: CGPoint(x: width - 8, y: y))
        }
    }

    private func enemyXPosition(
        distanceToGolemMeters: Double,
        laneWidth: CGFloat,
        contactX: CGFloat
    ) -> CGFloat {
        let rightSpawnX = laneWidth * 0.88

        let minDist = GolemMissionSlot.enemyAttackRangeMeters
        let maxDist = GolemMissionSlot.enemySpawnDistanceMeters
        let clamped = min(max(distanceToGolemMeters, minDist), maxDist)
        let fractionFromClose = (clamped - minDist) / max(maxDist - minDist, 0.0001)
        // fraction 0 => contactX (close), fraction 1 => rightSpawnX (far)
        return contactX + CGFloat(fractionFromClose) * (rightSpawnX - contactX)
    }

    private func enemyColor(for type: EnemyType) -> Color {
        switch type {
        case .slime: return .green
        case .raider: return .orange
        case .stoneBeast: return .gray
        }
    }

    private func golemShape(isWalking: Bool) -> some Shape {
        RoundedRectangle(cornerRadius: isWalking ? 10 : 6)
    }

    @ViewBuilder
    private func enemyShape(for type: EnemyType) -> some View {
        switch type {
        case .slime:
            Capsule()
        case .raider:
            RoundedRectangle(cornerRadius: 5)
        case .stoneBeast:
            RoundedRectangle(cornerRadius: 3)
        }
    }
}

#Preview {
    VStack {
        GolemMissionSideScrollerView(
            enemies: [
                .init(
                    type: .raider,
                    maxHealth: 12,
                    remainingHealth: 12,
                    distanceToGolemMeters: 5.0
                )
            ]
        )
        GolemMissionSideScrollerView(
            enemies: [
                .init(
                    type: .stoneBeast,
                    maxHealth: 16,
                    remainingHealth: 5,
                    distanceToGolemMeters: GolemMissionSlot.enemyAttackRangeMeters
                )
            ]
        )
    }
    .padding()
}
