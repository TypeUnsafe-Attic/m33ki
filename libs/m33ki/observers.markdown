
# Documentation for `m33ki.observers`




## Functions

### `Observer(executor)`

####Description

`Observer()` function returns an augmented structure (kind of class) to observing changes on ValueObjects or DynamicObjects.

#####Use, ie:

    let executor = getExecutor()

    let a = ValueObject(0)

    let obs1 = Observer(executor)
      : observable(a)
      : onChange(|currentValue, oldValue, thatObserver| {
          let data = [currentValue, oldValue]
          println(
            """
            ValueObject A has changed,
              old : <%= data: get(1) %>,
              new : <%= data: get(0) %>
            """: T("data", data)
          )
        })
      : observe()

or :

    let dyno = DynamicObject(): info(""): total(0)

    let obs2 = Observer(executor)
      : observable(dyno): delay(3000_L)
      : onChange(|currentValue, oldValue, thatObserver| {

          let data = [currentValue, oldValue]
          println(
            """
            DynamicObject DYNO has changed,
              old : <%= data: get(1): info() %> | <%= data: get(1): total() %>,
              new : <%= data: get(0): info() %> | <%= data: get(0): total() %>
            """:
            T("data", data)
          )
        })
      : observe(["info", "total"])

- see : [ValueObject](valueobjects.html)
- see : ["":T() (String template)](strings.html)

####Constructor `Observer(executor)`

Parameter: java.util.concurrent.ExecutorService.class

####Properties

- `observable(observableObject)` : this is a DynamicObject, or a struct or a m33ki.valueobjects.ValueObject with a `value` member
- `delay(delay)` : delay unit is milliseconds, ie: `delay(500_L)`, default is `100_L`

####Methods

- `onChange(|currentValue, oldValue, thatObserver| {})` this is a callback closure, triggered when value of observable change
- `observe()`
- `observe(tuple_of_members_to_observe)`
- `kill()` : observer stops observes observable



### `getExecutor()`




## Augmentations

### `m33ki.observers.types.observer`



#### `executor(this, executor)`



#### `kill(this)`



#### `observable(this, observable)`



#### `observe(this)`



#### `observe(this, members)`



#### `onChange(this, onChangeCallBack)`





## Structs

### `observer`



