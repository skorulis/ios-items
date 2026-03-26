import SwiftUI

@MainActor
struct GolemMissionSideScrollerView: View {
    let activityState: GolemMissionSlot.MissionActivityState

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
                        let enemyX = enemyXPosition(
                            state: activityState,
                            date: context.date,
                            laneWidth: width,
                            contactX: contactX
                        )

                        lanePath(y: laneY, width: width)
                            .stroke(Color.gray.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [7, 6]))

                        golemShape(isWalking: isWalking(state: activityState))
                            .fill(Color.accentColor)
                            .frame(width: 28, height: 36)
                            .offset(x: golemX, y: laneY - 36)

                        if let enemy = enemyDetails(state: activityState) {
                            enemyShape(for: enemy.type)
                                .foregroundStyle(enemyColor(for: enemy.type))
                                .frame(width: 28, height: 30)
                                .offset(x: enemyX, y: laneY - 30)
                        }
                    }
                }
                .frame(height: 112)

                if let enemy = enemyDetails(state: activityState) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(enemy.type.displayName)
                            .font(.appCaption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        ProgressView(value: enemy.remainingFraction)
                            .tint(.red)
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
        state: GolemMissionSlot.MissionActivityState,
        date: Date,
        laneWidth: CGFloat,
        contactX: CGFloat
    ) -> CGFloat {
        let rightSpawnX = laneWidth * 0.88
        switch state {
        case let .approachingEnemy(_, _, _, approachStartedAt, contactAt):
            let total = max(contactAt.timeIntervalSince(approachStartedAt), 0.001)
            let elapsed = max(0, min(total, date.timeIntervalSince(approachStartedAt)))
            let progress = elapsed / total
            return rightSpawnX - CGFloat(progress) * (rightSpawnX - contactX)
        case .combat:
            return contactX
        default:
            return rightSpawnX
        }
    }

    private func isWalking(state: GolemMissionSlot.MissionActivityState) -> Bool {
        switch state {
        case .combat:
            return false
        default:
            return true
        }
    }

    private func enemyDetails(state: GolemMissionSlot.MissionActivityState) -> EnemyDisplayDetails? {
        switch state {
        case let .approachingEnemy(type, enemyMaxHealth, enemyRemainingHealth, _, _):
            return .init(type: type, maxHealth: enemyMaxHealth, remainingHealth: enemyRemainingHealth)
        case let .combat(type, enemyMaxHealth, enemyRemainingHealth):
            return .init(type: type, maxHealth: enemyMaxHealth, remainingHealth: enemyRemainingHealth)
        default:
            return nil
        }
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

private struct EnemyDisplayDetails {
    let type: EnemyType
    let maxHealth: Int
    let remainingHealth: Int

    var remainingFraction: Double {
        guard maxHealth > 0 else { return 0 }
        return min(1, max(0, Double(remainingHealth) / Double(maxHealth)))
    }
}

#Preview {
    VStack {
        GolemMissionSideScrollerView(
            activityState: .approachingEnemy(
                type: .raider,
                enemyMaxHealth: 12,
                enemyRemainingHealth: 12,
                approachStartedAt: Date(),
                contactAt: Date().addingTimeInterval(2.5)
            )
        )
        GolemMissionSideScrollerView(
            activityState: .combat(
                type: .stoneBeast,
                enemyMaxHealth: 16,
                enemyRemainingHealth: 5
            )
        )
    }
    .padding()
}
