#ifndef USELESS_PLAYER_SHELL_H
#define USELESS_PLAYER_SHELL_H

#include "jqutil_v2/jqutil.h"

class ShellBridge : public JQUTIL_NS::JQBaseObject {
public:
  ShellBridge() = default;
  ~ShellBridge() override = default;

  void exec(JQUTIL_NS::JQFunctionInfo& info);
  static JSValue CreateClass(JQUTIL_NS::JQModuleEnv* env);
};

#endif
