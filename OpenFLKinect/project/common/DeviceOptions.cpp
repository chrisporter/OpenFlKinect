#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif


#include <hx/CFFI.h>
#include <vector>
#include "DeviceOptions.h"

using namespace openflkinect;
using namespace std;

DEFINE_KIND(k_DeviceOptions);

static value openflkinect_init_device_options(value in)
{
  value v;
  v = alloc_abstract(k_DeviceOptions, malloc(sizeof(DeviceOptions)));
  DeviceOptions* opts = ((DeviceOptions*)val_data(v));

  cout << "Hello World" << endl;
  //opts->deviceId = val_string(val_field(in, val_id("deviceId")));
  //cout << opts->deviceId.c_str() << endl;
  opts->irEnabled = val_bool(val_field(in, val_id("irEnabled")));

  return v;
}
DEFINE_PRIM (openflkinect_init_device_options, 1);

static value openflkinect_get_irEnabled(value v)
{
  val_check_kind(v, k_DeviceOptions);
  DeviceOptions* opts = ((DeviceOptions*)val_data(v));

  return alloc_bool(opts->irEnabled);
}i
DEFINE_PRIM (openflkinect_get_irEnabled, 1);

static void openflkinect_set_irEnabled(value v, value enabled)
{
  val_check_kind(v, k_DeviceOptions);
  val_check(enabled, bool);

  DeviceOptions* opts= ((DeviceOptions*)val_data(v));

  opts->irEnabled = val_bool(enabled);
}
DEFINE_PRIM (openflkinect_set_irEnabled, 2);

}

//extern "C" void openflkinect_main () {}
//DEFINE_ENTRY_POINT (openflkinect_main);


//extern "C" int openflkinect_register_prims () { return 0; }



