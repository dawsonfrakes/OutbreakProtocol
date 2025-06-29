module basic.macos;

enum STDOUT_FILENO = 1;

extern(C) ptrdiff_t write(int, const(void)*, size_t);
extern(C) noreturn _exit(int);

struct objc_Class__; alias objc_Class = objc_Class__*;
struct objc_SEL__; alias objc_SEL = objc_SEL__*;

extern(C) void objc_msgSend();
extern(C) objc_Class objc_getClass(const(char)*);
extern(C) objc_SEL sel_getUid(const(char)*);

struct NSApplication {
	enum ActivationPolicy : int {
		REGULAR = 0,
		ACCESSORY = 1,
		PROHIBITED = 2,
	}

	extern(C) static NSApplication* sharedApplication() {
		alias PFN = extern(C) NSApplication* function(objc_Class, objc_SEL);
		return (cast(PFN) &objc_msgSend)(objc_getClass("NSApplication"), sel_getUid("sharedApplication"));
	}

	extern(C) bool setActivationPolicy(ActivationPolicy policy) {
		alias PFN = extern(C) bool function(NSApplication*, objc_SEL, ActivationPolicy);
		return (cast(PFN) &objc_msgSend)(&this, sel_getUid("setActivationPolicy:"), policy);
	}
}

extern(C) bool NSApplicationLoad();
