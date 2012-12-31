### Attack!

Run the demo Rails application with

    rails server

Open another shell and run the Rake task to create the payload for the application:

    rake create-json[14]

The parameter in brackets ("14") determines how many collisions will be produced. It's 2^n collisions, so in this case 2^14 collisions would be generated.

Next, to execute the actual attack, run the following command:

    rake exploit-json[14]

Ensure that the parameter in brackets is the same as before.

(Note that this demonstration will work with 64 bit CRuby (< 1.9.3p327) only.)
