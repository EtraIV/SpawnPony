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
	version = "1.3",
	url = "https://boards.4chan.org/mlp/"
};

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
		char mdlname[64];
		char mdlpath[PLATFORM_MAX_PATH];
		float position[3];
		float angles[3];
		char animation[256];
		
		kv.GetSectionName(mdlname, sizeof(mdlname));
		kv.GetString("path", mdlpath, sizeof(mdlpath));
		kv.GetString("animation", animation, sizeof(animation));
		kv.GetVector("position", position);
		kv.GetVector("angles", angles);
		
		Entity_SpawnProp(mdlname, mdlpath, animation, position, angles);
	} while (kv.GotoNextKey());

	kv.Rewind();
	delete kv;
}

int Entity_SpawnProp(const char[] name, const char[] path,
	const char[] animation, float position[3], float angles[3])
{
	int newprop = CreateEntityByName("prop_dynamic");

	DispatchKeyValue(newprop, "targetname", name);
	DispatchKeyValue(newprop, "model", path);
	DispatchKeyValue(newprop, "solid", "0");
	DispatchKeyValue(newprop, "DisableBoneFollowers", "1");
	DispatchKeyValue(newprop, "DefaultAnim", animation);
	DispatchSpawn(newprop);
	TeleportEntity(newprop, position, angles, NULL_VECTOR);
	SetEntityMoveType(newprop, MOVETYPE_NONE);

	return newprop;
}
