import AppIntents
import SwiftUI
import WidgetKit

/// Stage 5b: a home-screen widget and a Control Center button that save a
/// location point without opening Cairn.
@main
struct CairnCaptureWidgets: WidgetBundle {
  var body: some Widget {
    CaptureWidget()
    if #available(iOS 18.0, *) {
      CaptureControl()
    }
  }
}

struct CaptureEntry: TimelineEntry {
  let date: Date
}

struct CaptureProvider: TimelineProvider {
  func placeholder(in context: Context) -> CaptureEntry { CaptureEntry(date: .now) }

  func getSnapshot(in context: Context, completion: @escaping (CaptureEntry) -> Void) {
    completion(CaptureEntry(date: .now))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<CaptureEntry>) -> Void) {
    completion(Timeline(entries: [CaptureEntry(date: .now)], policy: .never))
  }
}

struct CaptureWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "CaptureWidget", provider: CaptureProvider()) { _ in
      CaptureWidgetView()
    }
    .configurationDisplayName("Save point")
    .description("Save where you are to today's page.")
    .supportedFamilies([.systemSmall, .accessoryCircular])
  }
}

struct CaptureWidgetView: View {
  var body: some View {
    Button(intent: CapturePointIntent(source: "widget")) {
      VStack(spacing: 6) {
        Image(systemName: "triangle")
          .font(.title2)
        Text("Save point")
          .font(.caption.weight(.semibold))
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .buttonStyle(.plain)
    .containerBackground(for: .widget) {
      Color(red: 0.11, green: 0.114, blue: 0.102)
    }
    .foregroundStyle(Color(red: 0.969, green: 0.969, blue: 0.957))
  }
}

@available(iOS 18.0, *)
struct CaptureControl: ControlWidget {
  var body: some ControlWidgetConfiguration {
    StaticControlConfiguration(kind: "com.cairnjournal.app.capture-control") {
      ControlWidgetButton(action: CapturePointIntent(source: "control")) {
        Label("Save point", systemImage: "triangle")
      }
    }
    .displayName("Save point")
    .description("Save where you are to today's page in Cairn.")
  }
}
