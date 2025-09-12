// Canonical Flutter runner main.
#include "my_application.h"

int main(int argc, char** argv) {
	// Defer CEF initialization to when the WebView is actually created in Dart.
	g_autoptr(MyApplication) app = my_application_new();
	return g_application_run(G_APPLICATION(app), argc, argv);
}
