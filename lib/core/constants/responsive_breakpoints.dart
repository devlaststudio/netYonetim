class ResponsiveBreakpoints {
  const ResponsiveBreakpoints._();

  static const double mobileMaxWidth = 800;

  static bool isMobileWidth(double width) => width < mobileMaxWidth;
}
