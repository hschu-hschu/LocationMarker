# CustomBillBoardGui Usage

The `CustomBillBoardGui` module allows you to easily create and manage 2D GUI elements that are dynamically positioned based on game objects in Roblox. This module helps implement a location guide system that indicates the position of objects both inside and outside the screen.

## Installation and Usage

1. **Load the Module**: Import the `CustomBillBoardGui` module.
2. **Create a Billboard GUI**: Use the `CustomBillBoardGui.new()` function to create a new billboard GUI.
3. **Set Properties**: Configure the properties of the created billboard GUI.

### Example

Here's a simple example demonstrating how to create and set up a `CustomBillBoardGui`:

```lua
local CustomBillBoardGui = require(script.Parent)

local new = CustomBillBoardGui.new()
new.OutsideIconID = "http://www.roblox.com/asset/?id=4292970642"
new.Adornee = workspace:WaitForChild("Part")
new.Object.SizeConstraint = Enum.SizeConstraint.RelativeYY
new.Size = UDim2.fromScale(5, 5)
new.Object.ImageColor3 = Color3.new(1, 0, 0)
```

### Properties

- `OutsideIconID` (string): The URL of the icon to be displayed when the object is outside the screen.
- `Adornee` (BasePart | Model): The object in the workspace that the billboard GUI will follow.
- `Object.SizeConstraint` (Enum.SizeConstraint): Determines how the GUI element's size is constrained. Example: `Enum.SizeConstraint.RelativeYY`.
- `Size` (UDim2): The size of the GUI element when the object is inside the screen.
- `Object.ImageColor3` (Color3): The color of the GUI image.

### Note

Ensure that the module script is placed appropriately in your game hierarchy and that you have the necessary permissions to use the asset URLs provided.
