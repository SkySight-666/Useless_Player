#include "jqutil_v2/jqutil.h"
#include <jsmodules/JSCModuleExtension.h>
#include <jquick_config.h>

#include "Shell/Shell.h"

static std::vector<std::string> exportList = {
  "Shell",
};

static int module_init(JSContext* ctx, JSModuleDef* m) {
  auto env = JQUTIL_NS::JQModuleEnv::CreateModule(ctx, m, "player_native");
  env->setModuleExport("Shell", ShellBridge::CreateClass(env.get()));
  env->setModuleExportDone(JS_UNDEFINED, exportList);
  return 0;
}

DEF_MODULE_LOAD_FUNC_EXPORT(player_native, module_init, exportList);

extern "C" JQUICK_EXPORT void custom_init_jsapis() {
  registerCModuleLoader("player_native", &player_native_module_load);
}
