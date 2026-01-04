import 'package:flutter/widgets.dart';

enum DeviceSize { mobile, tablet, desktop }

DeviceSize deviceSizeOf(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width >= 1024) return DeviceSize.desktop;
  if (width >= 600) return DeviceSize.tablet;
  return DeviceSize.mobile;
}

extension DeviceSizeX on BuildContext {
  DeviceSize get deviceSize => deviceSizeOf(this);
  bool get isMobile => deviceSize == DeviceSize.mobile;
  bool get isTablet => deviceSize == DeviceSize.tablet;
  bool get isDesktop => deviceSize == DeviceSize.desktop;
}
