#pragma newdecls required
#pragma semicolon 1
#include <files>
#include <sdktools>
#include <sourcemod>
#include <tf2>

public Plugin myinfo = {
	name = "SpawnPony",
	author = "Etra",
	description = "Automatically spawns ponies into the map on roundstart.",
	version = "1.4",
	url = "https://boards.4chan.org/mlp/"
};

enum struct Pony {
	char name[64];
	char path[PLATFORM_MAX_PATH];
	char animation[256];
	char bodygroup[2];
	float position[3];
	float angles[3];
}

public void OnPluginStart()
{
	HookEvent("teamplay_round_start", SpawnPony);
}

public void SpawnPony(Handle event, const char[] name, bool dontBroadcast)
{
	char path[PLATFORM_MAX_PATH], mapname[PLATFORM_MAX_PATH];
	
	GetCurrentMap(mapname, sizeof(mapname));	
	BuildPath(Path_SM, path, sizeof(path), "configs/spawnpony/%s.cfg", mapname);
		
	if(!FileExists(path)) {
		SetFailState("Configuration file %s is not found.", path);
		return;
	}

	KeyValues kv = new KeyValues("SpawnPonies");
	if (!kv.ImportFromFile(path)) {
		SetFailState("Error importing config file %s", path);
		delete kv;
		return;
	}
	
	if (!kv.GotoFirstSubKey()) {
		SetFailState("Error reading first key from config file %s", path);
		delete kv;
		return;
	}
	
	do {
		Pony newpony;
		kv.GetSectionName(newpony.name, sizeof(newpony.name));
		kv.GetString("path", newpony.path, sizeof(newpony.path));
		kv.GetString("animation", newpony.animation, sizeof(newpony.animation));
		kv.GetString("bodygroup",newpony. bodygroup, sizeof(newpony.bodygroup));
		kv.GetVector("position", newpony.position);
		kv.GetVector("angles", newpony.angles);
		
		Entity_SpawnProp(newpony);
	} while (kv.GotoNextKey());

	kv.Rewind();
	delete kv;
}

int Entity_SpawnProp(Pony pony)
{
	int newprop = CreateEntityByName("prop_dynamic");

	DispatchKeyValue(newprop, "targetname", pony.name);
	DispatchKeyValue(newprop, "model", pony.path);
	DispatchKeyValue(newprop, "solid", "0");
	DispatchKeyValue(newprop, "DisableBoneFollowers", "1");
	DispatchKeyValue(newprop, "DefaultAnim", pony.animation);
	DispatchKeyValue(newprop, "SetBodyGroup", pony.bodygroup);
	DispatchSpawn(newprop);
	TeleportEntity(newprop, pony.position, pony.angles, NULL_VECTOR);
	SetEntityMoveType(newprop, MOVETYPE_NONE);

	return newprop;
}
