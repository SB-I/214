
Promise = {}

STATES = { WAITING = 0, FULFILLED = 1, REJECTED = 2 }

Promise.isPromise = function(maybePromise)
    if (type(maybePromise) == 'table') and maybePromise.isPromise~=nil and maybePromise.isPromise then
        return true
    else
        return false
    end
end

Promise.new = function()
    local p = {
        state = STATES['WAITING'],
        onSuccess = nil,
        onRejected = nil,
        isPromise = true,
        _next = nil,
        _result = nil,
        _rejectedReason = nil
    }

    function p:next(onSuccess) 
        --[[
        Execute the "onSuccess" callback function when 'self' resolves. Returns
        a promise that resolves when the promise returned by "onSuccess"
        resolves.
        ]]
        self.onSuccess = onSuccess

        local _p = Promise.new()
        self._next = _p

        -- if 'self' is already resolved, we need to execute _next now...
        if self.state == STATES['FULFILLED'] then
            local rc = onSuccess(self._result)
            if Promise.isPromise(rc) then
                rc.onSuccess = function(result)
                    _p:resolve(result)
                end
                rc.onRejected = function(reason)
                    _p:reject(reason)
                end
            else
                _p:resolve(rc)
            end
        end
        if self.state == STATES['REJECTED'] then
            _p:reject(self._rejectedReason)
        end
        return _p
    end

    function p:resolve(result)
        if self.state == STATES['REJECTED'] then
            -- Continue the rejection chain
            self:reject(self._rejectedReason)
            return
        end
        self._result = result
        if self and (self.onSuccess ~= nil) then
            local rc
            if self.state == STATES['WAITING'] then
                self.state = STATES['FULFILLED']
                rc = self.onSuccess(result)
            end
            -- rc might be a promise. If/when 'rc' resolves, we need to resolve
            -- the "self._next" promise as well.
            if Promise.isPromise(rc) then 
                if rc.state == STATES['WAITING'] then
                    if Promise.isPromise(self._next) then
                        if self._next.state == STATES['WAITING'] then
                            rc.onSuccess = function(result)
                                if Promise.isPromise(result) and result.state == STATES['REJECTED'] then
                                    self._next:reject(result._rejectedReason)
                                else
                                    self._next:resolve(result)
                                end
                            end

                            rc.onRejected = function(reason)
                                -- This subpromise was rejected. If there is
                                -- another promise in the chain, reject that too.
                                if self._next then
                                    self._next:reject(reason)
                                end
                            end
                        elseif self._next.state == STATES['REJECTED'] then
                        end
                    end
                elseif rc.state == STATES['FULFILLED'] then
                    self._next:resolve(rc._result)
                elseif rc.state == STATES['REJECTED'] then
                    self._next:reject(rc._rejectedReason)
                end
            else
                -- Pass 'rc' directly to the next callback, if there is one
                if Promise.isPromise(self._next) then
                    self._next:resolve(rc)
                end
            end
        else
            self.state = STATES['FULFILLED']
        end
    end

    function p:reject(reason)
        -- Reject the promise. If there are promises chained after this
        -- promise, reject those too.
        self.state = STATES['REJECTED']
        self._rejectedReason = reason
        if self and self.onRejected then
            self.onRejected(reason)
        elseif self and self._next then
            self._next:reject(reason)
        end
    end

    function p:catch( callback )
        -- If a rejection chain reaches a catch, call the callback
        self.onRejected = callback
    end

    return p
end

-- Create a resolved promise with a result
Promise.resolve = function(result)
    local p = Promise.new()
    p:resolve(result)
    return p
end

-- Create a rejected promise
Promise.reject = function(reason)
    local p = Promise.new()
    p:reject(reason)
    return p
end

-- Create a promise that resolves when all sub-promises resolve
Promise.all = function(promises)
    if #promises == 0 then
        return nil
    end
    if #promises == 1 then
        return promise
    end
    local promise = Promise.new()

    local onResolve = function(result)
        -- Check to see if all of the promises are resolved. If so, resolve our
        -- master promise
        local allResolved = true
        for i, p in ipairs(promises) do
            if p.state ~= STATES['FULFILLED'] then
                allResolved = false
                -- break
            end
        end
        if allResolved then
            promise:resolve(true)
        end
    end

    for i, p in ipairs(promises) do
        p:next(function(result)
            onResolve(result)
        end)
    end
    return promise
end

