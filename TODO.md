
In `module m33ki.hot` change exit code (ie: 5)

In `go.sh`, change starting error code : (ie: 9)

    #!/bin/sh

    RC=9
    #trap "echo CTRL-C was pressed" 2
    trap "exit 1" 2
    while [ $RC -ne 0 ] ; do
       echo "ERROR : $RC"
       golo golo --classpath jars/*.jar --files libs/*.golo main.golo
       RC=$?
    done

And then pass error code to `main.golo`
