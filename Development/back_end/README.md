# Server Structure

![(Server Structure](/Images/Project-Structure.jpg)

## Server Kernel:

- **What is it?**

  The server kernel is a robust, well-debugged layer of the program that manages the service layer and directly interacts with OS and files.
  We will have to make sure that the kernel layer **NEVER** crashes. 
  
- **What problem does it solve?**
  
  1. The server itself may crash because of unhandled exceptions, which requires manual recovery.
  2. We want to protect files and data.
  3. We want a shell interface to do administrative operations on files/server config., etc.
 

