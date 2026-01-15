@freestanding(declaration, names: arbitrary)
public macro AutoDefaultsSetting<T>(key: String, type: T.Type, default: T) =
  #externalMacro(
    module: "AutoDefaultsSettingMacros",
    type: "AutoDefaultsSettingMacro"
  )
