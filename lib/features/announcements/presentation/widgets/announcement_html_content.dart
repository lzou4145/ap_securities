import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:html/dom.dart' as dom;

/// Renders announcement body HTML (rich text, images) from the CMS.
class AnnouncementHtmlContent extends StatelessWidget {
  const AnnouncementHtmlContent({
    required this.html,
    super.key,
  });

  final String html;

  static const _bodyStyle = TextStyle(
    fontSize: 15,
    height: 1.55,
    color: Color(0xFF333333),
  );

  @override
  Widget build(BuildContext context) {
    final content = _normalizeAnnouncementHtml(html.trim());
    if (content.isEmpty) {
      return const SizedBox.shrink();
    }

    if (!content.contains('<')) {
      return SelectableText(content, style: _bodyStyle);
    }

    return HtmlWidget(
      content,
      textStyle: _bodyStyle,
      renderMode: RenderMode.column,
      customWidgetBuilder: (element) => _buildCustomWidget(context, element),
      customStylesBuilder: (element) {
        if (element.localName == 'img') {
          return null;
        }
        switch (element.localName) {
          case 'h1':
          case 'h2':
          case 'h3':
          case 'h4':
          case 'h5':
          case 'h6':
            return {
              'margin': '12px 0 6px',
              'font-weight': '600',
              'color': '#1A1A1A',
            };
          case 'p':
            return {'margin': '8px 0'};
          case 'a':
            return {'color': '#2D8BFF', 'text-decoration': 'none'};
        }
        return null;
      },
    );
  }

  Widget? _buildCustomWidget(BuildContext context, dom.Element element) {
    if (element.localName == 'img') {
      return _AnnouncementNetworkImage(
        url: _normalizeImageUrl(element.attributes['src'] ?? ''),
        widthFactor: _imageWidthFactor(element),
      );
    }
    return null;
  }
}

/// CMS HTML may contain JSON-escaped quotes in attributes.
String _normalizeAnnouncementHtml(String html) {
  if (!html.contains(r'\"') && !html.contains(r'\/')) {
    return html;
  }
  return html.replaceAll(r'\"', '"').replaceAll(r'\/', '/');
}

String _normalizeImageUrl(String raw) {
  var url = raw.trim();
  if (url.startsWith('"') && url.endsWith('"') && url.length > 1) {
    url = url.substring(1, url.length - 1);
  }
  return url.replaceAll(r'\"', '"').replaceAll(r'\/', '/').trim();
}

double _imageWidthFactor(dom.Element element) {
  final style = element.attributes['style'] ?? '';
  final match = RegExp(r'width:\s*([\d.]+)%').firstMatch(style);
  if (match != null) {
    final percent = double.tryParse(match.group(1)!);
    if (percent != null && percent > 0) {
      return (percent / 100).clamp(0.1, 1.0);
    }
  }
  return 1;
}

class _AnnouncementNetworkImage extends StatelessWidget {
  const _AnnouncementNetworkImage({
    required this.url,
    required this.widthFactor,
  });

  final String url;
  final double widthFactor;

  static const _horizontalPadding = 16.0 + 20.0;

  @override
  Widget build(BuildContext context) {
    if (!url.startsWith(RegExp('https?://', caseSensitive: false))) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final imageWidth = (screenWidth - _horizontalPadding * 2) * widthFactor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Image.network(
          url,
          width: imageWidth,
          fit: BoxFit.contain,
          gaplessPlayback: true,
          filterQuality: FilterQuality.medium,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return SizedBox(
              width: imageWidth,
              height: 160,
              child: const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return SizedBox(
              width: imageWidth,
              height: 120,
              child: const ColoredBox(
                color: Color(0xFFF4F6F9),
                child: Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 40,
                    color: Color(0xFFBDBDBD),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
