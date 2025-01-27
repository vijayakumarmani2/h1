#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <cstring>
#include <string>
#include <sstream>
#include <vector>
#include <stdlib.h>

// Execute shell commands
std::string exec(const char* cmd) {
    char buffer[128];
    std::string result = "";
    FILE* pipe = popen(cmd, "r");
    if (!pipe) return "ERROR";
    while (fgets(buffer, sizeof(buffer), pipe) != nullptr) {
        result += buffer;
    }
    pclose(pipe);
    return result;
}

// Get available WiFi networks
std::vector<std::string> getAvailableNetworks() {
    std::vector<std::string> networks;
    std::string output = exec("nmcli -t -f SSID device wifi list");
    std::istringstream stream(output);
    std::string line;

    while (std::getline(stream, line)) {
        if (!line.empty()) {
            networks.push_back(line);
        }
    }
    return networks;
}

// Get active WiFi network
std::string getActiveNetwork() {
    std::string output = exec("nmcli -t -f NAME,DEVICE connection show --active");
    std::istringstream stream(output);
    std::string line;

    while (std::getline(stream, line)) {
        if (line.find("wlan") != std::string::npos) { // Check if it's a WiFi device
            size_t pos = line.find(':');
            if (pos != std::string::npos) {
                return line.substr(0, pos); // Return the active WiFi SSID
            }
        }
    }
    return "";
}

// Connect to a WiFi network
bool connectToNetwork(const std::string& ssid, const std::string& password) {
    std::string command = "nmcli device wifi connect \"" + ssid + "\" password \"" + password + "\"";
    int result = system(command.c_str());
    return result == 0;
}

// Method call handler
static void wifi_manager_method_call(FlMethodChannel* channel,
                                     FlMethodCall* method_call,
                                     gpointer user_data) {
    const gchar* method = fl_method_call_get_name(method_call);

    if (strcmp(method, "getAvailableNetworks") == 0) {
        std::vector<std::string> networks = getAvailableNetworks();
        FlValue* result = fl_value_new_list();
        for (const std::string& network : networks) {
            fl_value_append_take(result, fl_value_new_string(network.c_str()));
        }
        fl_method_call_respond_success(method_call, result, nullptr);
    } else if (strcmp(method, "getActiveNetwork") == 0) {
        std::string activeNetwork = getActiveNetwork();
        fl_method_call_respond_success(method_call, fl_value_new_string(activeNetwork.c_str()), nullptr);
    } else if (strcmp(method, "connectToNetwork") == 0) {
        FlValue* args = fl_method_call_get_args(method_call);
        const gchar* ssid = fl_value_get_string(fl_value_lookup_string(args, "ssid"));
        const gchar* password = fl_value_get_string(fl_value_lookup_string(args, "password"));

        bool success = connectToNetwork(ssid, password);
        fl_method_call_respond_success(method_call, fl_value_new_bool(success), nullptr);
    } else {
        fl_method_call_respond_not_implemented(method_call, nullptr);
    }
}

int main(int argc, char** argv) {
    // Initialize GTK
    gtk_init(&argc, &argv);

    // Create the Flutter project and view
    g_autoptr(FlDartProject) project = fl_dart_project_new();
    g_autoptr(FlView) view = fl_view_new(project);

    // Create the GTK window and embed the Flutter view
    GtkWidget* window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    gtk_window_set_default_size(GTK_WINDOW(window), 1280, 800);
    gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

    // Connect window close signal
    g_signal_connect(window, "destroy", G_CALLBACK(gtk_main_quit), nullptr);

    // Create method channel
    g_autoptr(FlBinaryMessenger) messenger = fl_engine_get_binary_messenger(fl_view_get_engine(view));
    FlMethodCodec* codec = FL_METHOD_CODEC(fl_standard_method_codec_new()); // Corrected initialization
    g_autoptr(FlMethodChannel) channel =
        fl_method_channel_new(messenger, "wifi_manager", codec);
    fl_method_channel_set_method_call_handler(channel, wifi_manager_method_call, nullptr, nullptr);

    // Show the GTK window
    gtk_widget_show_all(window);

    // Run the GTK main loop
    gtk_main();

    return 0;
}
