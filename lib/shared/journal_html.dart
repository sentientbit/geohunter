import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import 'app_theme.dart';

/// Renders the Keeper's server-rendered HTML bodies into native widgets.
///
/// Backed by `flutter_widget_from_html_core` (fwfh-core): renders to RichText/
/// TextSpan, never a WebView, so there's no JS execution and no XSS surface.
/// Unknown/unsafe tags (SCRIPT, STYLE) are dropped by the parser; HTML entities
/// are decoded for free.
///
/// Handles the current Journal vocabulary (paragraphs, <em>/<strong> emphasis,
/// <br>, and the <blockquote> account voice rendered indented with a gold rule)
/// AND anything the Keeper grows into later — lists, headings, links, nested
/// markup — without further changes here.
///
/// Signature kept identical to the old hand-rolled renderer so call sites that
/// spread the result into a Column need no changes.
///
/// Returns a list of block widgets to drop into a Column.
List<Widget> renderJournalHtml(
  String html, {
  Color textColor = kSilver,
  double fontSize = 16,
}) {
  if (html.trim().isEmpty) return const [];
  return [
    HtmlWidget(
      html,
      // Base text styling for every span the body produces.
      textStyle: TextStyle(
        color: textColor,
        fontSize: fontSize,
        height: 1.6,
      ),
      // A simple Column is the default render mode — matches how the old
      // renderer's output was consumed. Switch to RenderMode.listView or
      // .sliverList if a body ever gets long enough to want lazy rendering.
      renderMode: RenderMode.column,
      // The account's own voice: indented, italic, gold rule on the left.
      // fwfh applies these as real CSS, so nested <p> inside the quote and any
      // future inline emphasis are handled by the parser, not by us.
      customStylesBuilder: (element) {
        switch (element.localName) {
          case 'blockquote':
            return {
              'margin': '0 0 14px 0',
              'padding': '0 0 0 14px',
              'border-left': '2px solid ${_rgba(kGold, 0.5)}',
              'font-style': 'italic',
            };
          case 'p':
            return {'margin': '0 0 14px 0'};
          default:
            return null;
        }
      },
      // Links render as styled text by default. fwfh-core does NOT launch URLs
      // on its own (that lives in fwfh_url_launcher) — handle taps here instead,
      // which keeps url_launcher out of the dep tree until you actually need it.
      onTapUrl: (url) {
        debugPrint('journal link tapped: $url');
        return true; // mark handled; wire up navigation when links go live
      },
    ),
  ];
}

/// Converts a [Color] to a `rgba(r, g, b, a)` CSS string for customStylesBuilder.
/// Uses the float component accessors (.r/.g/.b, 0..1) rather than the
/// deprecated .red/.green/.blue ints, matching the .withValues(...) era API.
String _rgba(Color c, double alpha) =>
    'rgba(${(c.r * 255).round()}, ${(c.g * 255).round()}, '
    '${(c.b * 255).round()}, $alpha)';
