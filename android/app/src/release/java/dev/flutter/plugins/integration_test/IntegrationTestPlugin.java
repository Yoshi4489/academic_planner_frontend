package dev.flutter.plugins.integration_test;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;

/**
 * Release-only no-op used for Flutter 3.41's generated registrant.
 *
 * The Flutter tool registers dev plugins in GeneratedPluginRegistrant.java,
 * while its Gradle plugin correctly removes them from the release classpath.
 * Keeping this empty implementation in the release source set prevents the
 * test framework and its Android dependencies from being shipped in the app.
 */
public final class IntegrationTestPlugin implements FlutterPlugin {
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {}

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {}
}
