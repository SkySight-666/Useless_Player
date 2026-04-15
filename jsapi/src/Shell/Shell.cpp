#include "Shell/Shell.h"

#include <array>
#include <cstdio>
#include <string>
#include <sys/wait.h>

namespace {

std::string RunCommand(const std::string& command, int* exit_code) {
  std::array<char, 512> buffer{};
  std::string output;

  std::string cmd = command + " 2>&1";
  FILE* pipe = popen(cmd.c_str(), "r");
  if (pipe == nullptr) {
    if (exit_code != nullptr) *exit_code = -1;
    return "popen failed";
  }

  while (fgets(buffer.data(), static_cast<int>(buffer.size()), pipe) != nullptr) {
    output += buffer.data();
  }

  const int status = pclose(pipe);
  if (exit_code != nullptr) {
    if (WIFEXITED(status)) *exit_code = WEXITSTATUS(status);
    else *exit_code = -1;
  }
  return output;
}

}  // namespace

void ShellBridge::exec(JQUTIL_NS::JQFunctionInfo& info) {
  JSContext* ctx = info.GetContext();
  if (info.Length() < 1 || !JS_IsString(info[0])) {
    JS_ThrowTypeError(ctx, "exec requires command string");
    return;
  }

  const char* cstr = JS_ToCString(ctx, info[0]);
  if (cstr == nullptr) return;
  std::string command = cstr;
  JS_FreeCString(ctx, cstr);

  int exit_code = -1;
  const std::string output = RunCommand(command, &exit_code);

  JSValue response = JS_NewObject(ctx);
  JS_SetPropertyStr(ctx, response, "code", JS_NewInt32(ctx, exit_code));
  JS_SetPropertyStr(ctx, response, "output", JS_NewString(ctx, output.c_str()));
  info.GetReturnValue().Set(response);
}

JSValue ShellBridge::CreateClass(JQUTIL_NS::JQModuleEnv* env) {
  auto tpl = JQUTIL_NS::JQFunctionTemplate::New(env, "Shell");
  tpl->InstanceTemplate()->setObjectCreator([]() { return new ShellBridge(); });
  tpl->SetProtoMethod("exec", &ShellBridge::exec);
  return tpl->CallConstructor();
}
