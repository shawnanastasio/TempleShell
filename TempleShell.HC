#define CMDS_LEN 9
U8 *cmds[CMDS_LEN] = {"cp", "mv", "mkdir", "rm", "edit", "cd", "ls", "exit", "help"};
U8 *cmds_help[CMDS_LEN] = {"Copy a file", "Move a file", "Make a direcotry", "Remove a file", "Edit a file", "Change Directory", "List files in directory", "Exit shell", "Display help"};

#define MAX_ARG_LEN 50

class args
{
  U8 **argv;
  I64 argc;
};

// Check if string begins with any string in
// supplied array
I8 StrInArray(U8* str, U8 **arr, I64 len)
{
  I64 i;
  for (i=0; i<len; i++)
  {
    if (StrNCmp(str, arr[i], StrLen(arr[i])) == 0) {
      return 1;
    }
  }
  return 0;
}


I64 GetNumArgs(U8 *input)
{
  I64 i, count = 0;
  for (i=0; i<StrLen(input); i++)
  {
    if (input[i] == ' ') {
      ++count;
    }
  }
  return count;
}

args *GetArgs(U8 *input)
{
  I64 num_args = GetNumArgs(input);
  
  // Allocate space for response
  args *toret = ACAlloc(sizeof(args));
  toret->argc = num_args;
  toret->argv = ACAlloc(sizeof(U8*) * num_args);
  I64 i, j, k;
  for (i=0; i<num_args; i++)
  {
    toret->argv[i] = ACAlloc(sizeof(U8) * MAX_ARG_LEN);
  }
  
  // Skip past command
  for (i=0; i<StrLen(input); i++)
  {
    if (input[i] == ' ') {
      break;
    }
  }
  ++i;

  // Add args to array
  for (j=0; j<num_args; j++)
  {
    k = 0;
    // Copy chars until space
    for (; i<StrLen(input); i++)
    {
      if (input[i] == ' ') {
        break;
      }
      toret->argv[j][k] = input[i];
      ++k;
    }
    toret->argv[j][k] = '\0';
    ++i;
  }
  return toret;
}

// Free an args object
U0 FreeArgs(args *tofree)
{
  I64 i;
  for (i=0; i<tofree->argc; i++)
  {
    Free(tofree->argv[i]);
  }
  Free(tofree->argv);
  Free(tofree);
}

U0 PrintHelp()
{
  "Available commands:\n";
  I64 i;
  for (i=0; i<CMDS_LEN; i++)
  {
    "%s - %s\n", cmds[i], cmds_help[i];
  }
}
  

// Handle command
I8 HandleCmd(U8 *input)
{


  // Replace this with something
  // better than ifelse spam

  I64 num_args;
  args *cur_args;

  // cd
  if (StrNCmp(input,"cd",2) == 0) {
   // Parse arguments
   num_args = GetNumArgs(input);
   if (num_args != 1) {
     "ERROR: 1 argument expected!\n";
     return 1;
   }

   cur_args = GetArgs(input);
   Cd(cur_args->argv[0]);
   
   // Free args
   FreeArgs(cur_args);
  }
  // exit
  else if (StrNCmp(input,"exit",4) == 0) {
    return 0;
  }
  // ls
  else if (StrNCmp(input,"ls",2) == 0) {
    num_args = GetNumArgs(input);
    if (num_args != 0 && num_args != 1) {
      "ERROR: 0/1 argument expected!\n";
      return 1;
    }

    if (num_args == 1) {
      cur_args = GetArgs(input);
      Dir(cur_args->argv[0]);
      FreeArgs(cur_args);
    } else {
      Dir;
    }
  }
  // help
  else if (StrNCmp(input,"help",4) == 0) {
    PrintHelp();
    return 1;
  }
  // edit
  else if (StrNCmp(input,"edit",4) == 0) {
    num_args = GetNumArgs(input);
    if (num_args != 1) {
      "ERROR: 1 argument expected!\n";
      return 1;
    }
    
    cur_args = GetArgs(input);
    Ed(cur_args->argv[0]);
    FreeArgs(cur_args);
  }
  // cp
  else if (StrNCmp(input,"cp",2) == 0) {
    num_args = GetNumArgs(input);
    if (num_args != 2) {
      "ERROR: 2 arguments expected!\n";
      return 1;
    }
    cur_args = GetArgs(input);
    Copy(cur_args->argv[0], cur_args->argv[1]);
    FreeArgs(cur_args);
  }
  // mv
  else if (StrNCmp(input,"mv",2) == 0) {
    num_args = GetNumArgs(input);
    if (num_args != 2) {
      "ERROR: 2 arguments expected!\n";
      return 1;
    }
    cur_args = GetArgs(input);
    Copy(cur_args->argv[0], cur_args->argv[1]);
    FreeArgs(cur_args);
  }
  // mkdir
  else if (StrNCmp(input,"mkdir",5) == 0) {
    num_args = GetNumArgs(input);
    if (num_args != 1) {
      "ERROR: 1 argument expected!\n";
      return 1;
    }
    cur_args = GetArgs(input);
    DirMk(cur_args->argv[0]);
    FreeArgs(cur_args);
  }
  // rm
  else if (StrNCmp(input,"rm",2) == 0) {
    num_args = GetNumArgs(input);
    if (num_args != 1) {
      "ERROR: 1 argument expected!\n";
      return 1;
    }
    cur_args = GetArgs(input);
    Del(cur_args->argv[0]);
    FreeArgs(cur_args);
  }
}


U0 TempleShell()
{
  "Welcome to TempleShell!\n";
  "Type 'help' for a list of commands.\n\n";
  while (1) 
  {
    // Display prompt
    "%s # ",Fs->cur_dir;

    // Grab user input
    U8 *input = GetStr();
    // Remove all shift spaces
    I64 i;
    for (i=0; i<StrLen(input); i++)
    {
      if (input[i] == 31) input[i] = ' ';
    }


    // Ignore empty command
    if (StrLen(input) == 0) goto skip_cmd;

    // Check if user entered overridden command
    if (StrInArray(input, cmds, CMDS_LEN)) {
      I64 res = HandleCmd(input);
      if (!res) return;
    } else {
    // Otherwise, ignore
      "ERROR: Unrecognized command!\n";
    }  

  skip_cmd:
    Free(input);
  }
}

TempleShell;
