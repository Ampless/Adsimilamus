FROM dart:stable AS build
WORKDIR /app
COPY pubspec.* bin/adsimilamus.dart ./
RUN dart pub get
RUN dart compile exe adsimilamus.dart -o adsimilamus

# Build minimal serving image from AOT-compiled `/server` and required system
# libraries and configuration files stored in `/runtime/` from the build stage.
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/adsimilamus /app/
EXPOSE 8043
CMD ["/app/adsimilamus"]
