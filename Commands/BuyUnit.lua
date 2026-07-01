-- get madatory module operators
VFS.Include("modules.lua") -- modules table
VFS.Include(modules.attach.data.path .. modules.attach.data.head) -- attach lib module

-- get other madatory dependencies
attach.Module(modules, "message") -- communication backend load

function getInfo()
	return {
		onNoUnits = SUCCESS, -- instant success
		tooltip = "Buy unit in param",
		parameterDefs = {
			{ 
				name = "unitName",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "'armbox'",
			},
		}
	}
end

function Run(self, units, parameter)
    message.SendRules({
        subject = "swampdota_buyUnit",
        data = {
			unitName = parameter.unitName
		},
    })
	
	return SUCCESS
end


function Reset(self)
	return self
end