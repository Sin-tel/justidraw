local ffi = require("ffi")

tabletInput = false

Tablet = {}

local wt
local hctx
local pressureLimits
local glogContext

Tablet.erase = false

function Tablet.init()
	local ok, lib = pcall(ffi.load, "wintab32.dll")

	if ok then
		wt = lib

		local sdl = ffi.load("SDL2")

		--SDL typedefs
		ffi.cdef([[
		typedef void SDL_Window;
		typedef enum
		{
		SDL_FALSE = 0,
		SDL_TRUE = 1
		} SDL_bool;

		typedef void *PVOID;
		typedef PVOID HANDLE;
		typedef HANDLE HWND;
		typedef HANDLE HDC;

		typedef struct SDL_version
		{
		unsigned char major;
		unsigned char minor;
		unsigned char patch;
		} SDL_version;

		typedef enum
		{
		SDL_SYSWM_UNKNOWN,
		SDL_SYSWM_WINDOWS,
		SDL_SYSWM_X11,
		SDL_SYSWM_DIRECTFB,
		SDL_SYSWM_COCOA,
		SDL_SYSWM_UIKIT,
		} SDL_SYSWM_TYPE;

		typedef struct
		{
		SDL_version version;
		SDL_SYSWM_TYPE subsystem;
		union
		{
		struct
		{
		HWND window;                /* The window handle */
		HDC hdc;                    /* The window device context */
		} win;
		} info;
		} SDL_SysWMinfo;

		]])

		--get the window handle from SDL
		ffi.cdef([[
		SDL_Window* SDL_GL_GetCurrentWindow (void);
		SDL_bool SDL_GetWindowWMInfo(SDL_Window* window, SDL_SysWMinfo* wmInfo);
		]])

		local sdlWindow = sdl.SDL_GL_GetCurrentWindow()

		local wmInfo = ffi.new("SDL_SysWMinfo[1]", {})

		print("get sdl window handle")
		print(sdl.SDL_GetWindowWMInfo(sdlWindow, wmInfo))
		local hwnd = wmInfo[0].info.win.window
		print(hwnd)

		--winapi and wintab typedefs
		ffi.cdef([[
		typedef unsigned int UINT;
		typedef char TCHAR;
		typedef unsigned long DWORD;
		typedef DWORD FIX32;
		typedef long LONG;
		typedef void *LPVOID;
		typedef int BOOL;
		typedef void *PVOID;
		typedef PVOID HANDLE;
		typedef HANDLE HWND;
		typedef HANDLE HCTX;

		typedef DWORD WTPKT;

		typedef struct tagLOGCONTEXT {
		TCHAR       lcName[40];
		UINT        lcOptions;
		UINT        lcStatus;
		UINT        lcLocks;
		UINT        lcMsgBase;
		UINT        lcDevice;
		UINT        lcPktRate;
		WTPKT       lcPktData;
		WTPKT       lcPktMode;
		WTPKT       lcMoveMask;
		DWORD       lcBtnDnMask;
		DWORD       lcBtnUpMask;
		LONG        lcInOrgX;
		LONG        lcInOrgY;
		LONG        lcInOrgZ;
		LONG        lcInExtX;
		LONG        lcInExtY;
		LONG        lcInExtZ;
		LONG        lcOutOrgX;
		LONG        lcOutOrgY;
		LONG        lcOutOrgZ;
		LONG        lcOutExtX;
		LONG        lcOutExtY;
		LONG        lcOutExtZ;
		FIX32       lcSensX;
		FIX32       lcSensY;
		FIX32       lcSensZ;
		BOOL        lcSysMode;
		int         lcSysOrgX;
		int         lcSysOrgY;
		int         lcSysExtX;
		int         lcSysExtY;
		FIX32       lcSysSensX;
		FIX32       lcSysSensY;
		} LOGCONTEXT;

		typedef LOGCONTEXT* LPLOGCONTEXT;

		typedef struct tagAXIS {
		LONG	axMin;
		LONG	axMax;
		UINT	axUnits;
		FIX32	axResolution;
		} AXIS;

		typedef struct tagORIENTATION {
		int orAzimuth;
		int orAltitude;
		int orTwist;
		} ORIENTATION;

		typedef struct tagROTATION {
		int roPitch;
		int roRoll;
		int roYaw;
		} ROTATION;

		typedef struct tagPACKET {
		UINT	pkCursor;
		DWORD	pkButtons;
		LONG	pkX;
		LONG	pkY;
		UINT	pkNormalPressure;

		} PACKET;

		typedef struct tagPOINT {
		LONG x;
		LONG y;
		} POINT;



		UINT WTInfoA(UINT wCategory, UINT nIndex, LPVOID lpOutput);
		HCTX WTOpenA(HWND hWnd, LPLOGCONTEXT lpLogCtx,BOOL fEnable);
		BOOL WTClose(HCTX hCtx);
		int WTPacketsGet(HCTX hCtx,int cMaxPkts,LPVOID lpPkts);
		]])

		print("setup wintab")

		assert(wt.WTInfoA(0, 0, nil), "WinTab Services Not Available.")

		pressureLimits = ffi.new("AXIS[1]", {})

		--get max pressure
		wt.WTInfoA(100, 15, pressureLimits) --WTI_DEVICES, DVC_NPRESSURE

		glogContext = ffi.new("LOGCONTEXT[1]", {})

		glogContext[0].lcOptions = 1 --glogContext.lcOptions |= CXO_SYSTEM;

		wt.WTInfoA(4, 0, glogContext) -- WTI_DEFSYSCTX = 4

		--We process WT_PACKET (CXO_MESSAGES) messages.
		glogContext[0].lcOptions = glogContext[0].lcOptions + 4
		-- What data items we want to be included in the tablet packets
		-- glogContext.lcPktData = PACKETDATA;
		-- PACKETDATA = (PK_X | PK_Y | PK_BUTTONS | PK_NORMAL_PRESSURE | PK_CURSOR)
		glogContext[0].lcPktData = 0x5E0 --0x5E0
		-- Which packet items should show change in value since the last
		-- packet (referred to as 'relative' data) and which items
		-- should be 'absolute'.
		--glogContext.lcPktMode = PACKETMODE; (= PK_BUTTONS)
		glogContext[0].lcPktMode = 0x0040
		-- This bitfield determines whether or not this context will receive
		-- a packet when a value for each packet field changes.  This is not
		-- supported by the Intuos Wintab.  Your context will always receive
		-- packets, even if there has been no change in the data.
		-- glogContext.lcMoveMask = PACKETDATA;
		glogContext[0].lcMoveMask = glogContext[0].lcPktData
		-- Which buttons events will be handled by this context.  lcBtnMask
		-- is a bitfield with one bit per button.
		glogContext[0].lcBtnUpMask = glogContext[0].lcBtnDnMask

		hctx = wt.WTOpenA(hwnd, glogContext, 1)
		print(hctx)

		--[[print("-------")
		print(glogContext[0].lcInOrgX,glogContext[0].lcInOrgY)
		print(glogContext[0].lcInExtX,glogContext[0].lcInExtY)
		print(glogContext[0].lcOutOrgX,glogContext[0].lcOutOrgY)
		print(glogContext[0].lcOutExtX,glogContext[0].lcOutExtY)
		print("-------")
		print(glogContext[0].lcSysOrgX,glogContext[0].lcSysOrgY)
		print(glogContext[0].lcSysExtX,glogContext[0].lcSysExtY)]]
	else
		print("no wintab found!")
		print(lib)
	end
end

function Tablet.update()
	if wt then
		--get max 20 packets (should be more than enough, my tablet sends packets at 250Hz)
		local pkt = ffi.new("PACKET[20]", {})
		local npkt = wt.WTPacketsGet(hctx, 20, pkt)

		if npkt > 0 then
			tabletInput = true

			for i = 0, npkt - 1 do
				local b = pkt[i].pkButtons
				if b > 0 then
					local b1 = b % 0x10000
					local b2 = math.floor(b / 0xFFFF)
					local button = 1
					if b1 == 2 then
						button = 2
					elseif b1 == 1 then
						button = 3
					end
					if b2 == 2 then
						mousepressed(button)
					else
						mousereleased(button)
					end
				end
				Tablet.erase = pkt[i].pkCursor == 2
			end
			local i = npkt - 1

			pres = pkt[i].pkNormalPressure / pressureLimits[0].axMax
			pres = pres * pres --add curve

			local xo, yo, _ = love.window.getPosition()

			mouseX, mouseY = pkt[i].pkX - xo, -yo - pkt[i].pkY + glogContext[0].lcSysExtY
		else
			tabletInput = false
			mouseX, mouseY = love.mouse.getPosition()
		end
	else
		tabletInput = false
		mouseX, mouseY = love.mouse.getPosition()
	end
end

function Tablet.close()
	if wt then
		wt.WTClose(hctx)
	end
end
