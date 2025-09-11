// Canonical Flutter runner main with CEF initialization.
#include <webview_cef/webview_cef_plugin.h>
#include "my_application.h"

int main(int argc, char** argv) {
	// Initialize CEF processes before starting GTK/Flutter loop.
	initCEFProcesses(argc, argv);
	g_autoptr(MyApplication) app = my_application_new();
	return g_application_run(G_APPLICATION(app), argc, argv);
}
