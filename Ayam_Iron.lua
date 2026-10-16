local Players=game:GetService("Players")
local me=Players.LocalPlayer
local PART,PARENT="Root","Portal"   -- nama part portal
local CLEAR_TEXT="cleared"          -- teks "Room Cleared"
local CLEAR_WAIT,EMPTY=6,45
getgenv().AP_id=(getgenv().AP_id or 0)+1
local id=getgenv().AP_id
local function hasEnemy()
 for _,h in ipairs(workspace:GetDescendants()) do
  if h:IsA("Humanoid") and h.Health>0 then
   local m=h.Parent
   if m~=me.Character and not Players:GetPlayerFromCharacter(m) then return true end
  end
 end
 return false
end
local function vis(o,pg)
 while o and o~=pg do
  if (o:IsA("GuiObject") and not o.Visible) or (o:IsA("ScreenGui") and not o.Enabled) then return false end
  o=o.Parent
 end
 return true
end
local function clearedText()
 local pg=me:FindFirstChild("PlayerGui") if not pg then return false end
 for _,o in ipairs(pg:GetDescendants()) do
  if o:IsA("TextLabel") and o.Text~="" and o.Text:lower():find(CLEAR_TEXT,1,true) and vis(o,pg) then return true end
 end
 return false
end
local function findPortal(from)
 local best,bd
 for _,o in ipairs(workspace:GetDescendants()) do
  if o:IsA("BasePart") and o.Name==PART and o.Parent and o.Parent.Name==PARENT then
   local d=(o.Position-from).Magnitude
   if not bd or d<bd then best,bd=o,d end
  end
 end
 return best
end
local lastE,lastP,saw,roomStart=os.clock(),0,false,os.clock()
task.spawn(function()
 while getgenv().AP_id==id do
  task.wait(1)
  local root=me.Character and me.Character:FindFirstChild("HumanoidRootPart")
  if root and getgenv().AutoFarm then
   local now=os.clock()
   if hasEnemy() then
    lastE=now saw=true
   elseif now-lastP>=12 then
    local clear=clearedText() or (saw and now-lastE>=CLEAR_WAIT)
    local stuck=now-roomStart>=EMPTY
    if clear or stuck then
     local p=findPortal(root.Position)
     if p then
      for i=1,6 do
       root.CFrame=CFrame.new(p.Position+Vector3.new(0,2,0))
       if firetouchinterest then
        pcall(firetouchinterest,root,p,0) pcall(firetouchinterest,root,p,1)
       end
       task.wait(0.35)
      end
      lastP,lastE,saw,roomStart=os.clock(),os.clock(),false,os.clock()
      print("[Portal] masuk:",p:GetFullName())
     end
    end
   end
  end
 end
end)
print("[AutoPortal v2] jalan")
