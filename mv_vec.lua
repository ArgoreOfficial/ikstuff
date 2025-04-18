local vec3_meta = {}

function _G.vec3(_x,_y,_z)
    local vec = setmetatable({ X=_x, Y=_y, Z=_z }, vec3_meta)
    return vec
end

function _G.vec2(_x,_y)
    return vec3(_x,_y,0)
end

function vec3_meta.__tostring(_vec) 
    return string.format("%.1f", _vec.X) .. ", " 
        .. string.format("%.1f", _vec.Y) .. ", " 
        .. string.format("%.1f", _vec.Z)
end

function vec3_meta.__mul(_vec,_scalar)
    return vec3(
        _vec.X * _scalar, 
        _vec.Y * _scalar, 
        _vec.Z * _scalar
    )
end

function vec3_meta.__div(_vec,_scalar)
    return vec3(
        _vec.X / _scalar, 
        _vec.Y / _scalar, 
        _vec.Z / _scalar
    )
end

function vec3_meta.__add(_lhs,_rhs)
    if type(_lhs) == "number" then
        return vec3(
            _lhs + _rhs.X, 
            _lhs + _rhs.Y, 
            _lhs + _rhs.Z
        )
    elseif type(_rhs) == "number" then
        return vec3(
            _lhs.X + _rhs, 
            _lhs.Y + _rhs, 
            _lhs.Z + _rhs
        )
    else
        return vec3(
            _lhs.X + _rhs.X, 
            _lhs.Y + _rhs.Y, 
            _lhs.Z + _rhs.Z
        )
    end
end

function vec3_meta.__sub(_lhs,_rhs)
    if type(_lhs) == "number" then
        return vec3(
            _lhs - _rhs.X, 
            _lhs - _rhs.Y, 
            _lhs - _rhs.Z
        )
    elseif type(_rhs) == "number" then
        return vec3(
            _lhs.X - _rhs, 
            _lhs.Y - _rhs, 
            _lhs.Z - _rhs
        )
    else
        return vec3(
            _lhs.X - _rhs.X, 
            _lhs.Y - _rhs.Y, 
            _lhs.Z - _rhs.Z
        )
    end
end

function vec3_meta.__unm(_vec)
    return vec3(
        -_vec.X, 
        -_vec.Y, 
        -_vec.Z
    )
end

function vec3_meta.__eq(_lhs,_rhs)
    return 
        _lhs.X == _rhs.X and
        _lhs.Y == _rhs.Y and
        _lhs.Z == _rhs.Z
end

function _G.vec2_from_angle(_angle, _length)
    return vec2( math.cos(_angle), math.sin(_angle) ) * _length
end

function _G.vec2_to_angle(_vec)
    return math.atan2(_vec.Y, _vec.X)
end

function _G.vec2_len(_vec2)
    return math.sqrt( _vec2.X^2 + _vec2.Y^2 )
end

function _G.vec2_normalize(_vec2, _length)
    local len = vec2_len(_vec2)
    return vec2(
        _vec2.X / len,
        _vec2.Y / len
    ) * (_length or 1.0)
end

return nil