package in.medbridge.business;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterShellArgs;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.view.FlutterMain;

public class MainActivity extends FlutterActivity {
  // FIXME: Remove onCreate and software rendering. Remove when issue resolved. Why below code? App stops on certain phones
  @java.lang.Override
  protected void onCreate(android.os.Bundle savedInstanceState) {
    FlutterMain.ensureInitializationComplete(getContext(), new String[]{FlutterShellArgs.ARG_ENABLE_SOFTWARE_RENDERING});
    super.onCreate(savedInstanceState);
  }

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
  }
}
