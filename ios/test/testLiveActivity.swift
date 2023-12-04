//
//  testLiveActivity.swift
//  test
//
//  Created by Code Dev on 06/11/23.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct testAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct testLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: testAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension testAttributes {
    fileprivate static var preview: testAttributes {
        testAttributes(name: "World")
    }
}

extension testAttributes.ContentState {
    fileprivate static var smiley: testAttributes.ContentState {
        testAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: testAttributes.ContentState {
         testAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: testAttributes.preview) {
   testLiveActivity()
} contentStates: {
    testAttributes.ContentState.smiley
    testAttributes.ContentState.starEyes
}
