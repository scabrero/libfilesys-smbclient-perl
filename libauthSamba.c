#include <stdio.h>
#include <string.h>
#include "libauthSamba.h"

char User[30];
char Password[30];
char Workgroup[30];

/*-----------------------------------------------------------------------------
 * set_fn
 *---------------------------------------------------------------------------*/
void set_fn(char *workgroup,
	    char *username,
	    char *password)
{  
#ifdef VERBOSE
  printf("set_fn\n");
#endif

  strcpy(User, username);
  strcpy(Password, password);
  /* set workgroup only when set */
  if (workgroup[0] && workgroup[0] != 0) {
#ifdef VERBOSE
    fprintf("Workgroup is set to %s", workgroup);
#endif
    strcpy(Workgroup, workgroup);
  }
}

/*-----------------------------------------------------------------------------
 * auth_fn
 *---------------------------------------------------------------------------*/
void auth_fn(const char *server, 
	     const char *share,
	     char *workgroup, int wgmaxlen,
	     char *username, int unmaxlen,
	     char *password, int pwmaxlen) {

#ifdef VERBOSE
  printf("auth_fn\n");
#endif

  /* set workgroup only when set */
  if (Workgroup[0] && Workgroup[0] != 0) {
#ifdef VERBOSE
    fprintf("Workgroup is set to %s", Workgroup);
#endif
    strcpy(workgroup, Workgroup);
    wgmaxlen = 30;
  }
  strcpy(username, User);
  unmaxlen = 30;
  strcpy(password, Password);
  pwmaxlen = 30;

#ifdef VERBOSE
  fprintf(stdout, "username: [%s]\n", username);
  fprintf(stdout, "password: [%s]\n", password);
  fprintf(stdout, "workgroup: [%s]\n", workgroup);
#endif


}

/*-----------------------------------------------------------------------------
 * ask_auth_fn
 *---------------------------------------------------------------------------*/
void ask_auth_fn(const char *server, 
	     const char *share,
	     char *workgroup, int wgmaxlen,
	     char *username, int unmaxlen,
	     char *password, int pwmaxlen)
{  
  char temp[128];

  fprintf(stdout, "Need password for //%s/%s\n", server, share);

  fprintf(stdout, "Enter workgroup: [%s] ", workgroup);
  fgets(temp, sizeof(temp), stdin);

  if (temp[strlen(temp) - 1] == 0x0a) /* A new line? */
    temp[strlen(temp) - 1] = 0x00;

  if (temp[0]) strncpy(workgroup, temp, wgmaxlen - 1);

  fprintf(stdout, "Enter username: [%s] ", username);
  fgets(temp, sizeof(temp), stdin);

  if (temp[strlen(temp) - 1] == 0x0a) /* A new line? */
    temp[strlen(temp) - 1] = 0x00;

  if (temp[0]) strncpy(username, temp, unmaxlen - 1);

  fprintf(stdout, "Enter password: [%s] ", password);
  fgets(temp, sizeof(temp), stdin);

  if (temp[strlen(temp) - 1] == 0x0a) /* A new line? */
    temp[strlen(temp) - 1] = 0x00;

  if (temp[0]) strncpy(password, temp, pwmaxlen - 1); 
}
