require "mv_vec"

function _G.lerp(_a, _b, _t)
	return _a + (_b - _a) * _t
end
