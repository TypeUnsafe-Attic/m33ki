module m33ki.futures

import java.util.concurrent.Executors

function getExecutor = -> Executors.newCachedThreadPool()

augment java.util.concurrent.Future {
	# callBackWhenException is a callBack when exception
	function getResult = |this, callBackWhenException| {
		var r  = null
		try {
			r = this:get()
		} catch (e) {
			if callBackWhenException isnt null { callBackWhenException(e) }
		} finally {
			return r
		}
	}

	function getResult = |this| {
		var r  = null
		try {
			r = this:get()
		} finally {
			return r
		}
	}

	function cancelTask = |this, callBackWhenCancelled| {
		this:cancel(true)
		callBackWhenCancelled(this:isCancelled())
	}
}

function Future = |executor, callable| -> DynamicObject()
    :executor(executor)
    :submit(|this, message| {
        #let worker = (-> callable(message)):to(java.util.concurrent.Callable.class)
        return this: executor(): submit(callable(message)) #future is run when submit()
    })

