#include <stdlib.h>

// string comparison

int compare(char *s1, char *s2)
{ while(1)
    {
      if (*s1 < *s2) return -1;
      if (*s1 > *s2) return 1;
      if (*s1 == 0)  return 0;
      s1++; s2++;
    }
}

typedef struct node
{ struct node *left, *right;
  char *key;
  int value;
} node;

node *mknode(char *key, int val, node *left, node *right)
{ node *t = malloc(sizeof(node));
  t->key   = key; //!!
  t->value = val;
  t->left  = left;
  t->right = right;
}

node *root = NULL;

void init(void)
{ root = NULL; }

void insert(char*key, int val)
{
  node **t = &root;
  while (1) {
    if(*t == NULL) {
      *t = mknode(key, val, NULL, NULL);
      return;
    }
    switch(compare(key, (*t)->key)) {
    case 1:
      t = &(**t).right;
      break;
    case -1:
      t = &(**t).left;
      break;
    case 0:
      return;
    }
  }
}

int lookup(char*key)
{ node *t = root;
  while(1)
    { if (t == NULL) return -1;
      int c = compare(key, t->key);
      switch (c)
        { case 1:  t=t->right; break;
          case -1: t=t->left; break;
          case 0:  return t->value;
        }
    }
}

void update(char*key, int val)
{
  node **t = &root;
  while (1) {
    switch(compare(key, (*t)->key)) {
    case 1:
      t = &(**t).right;
      break;
    case -1:
      t = &(**t).left;
      break;
    case 0:
      (*t)->value = val;
      return;
    }
  }
}

void delete(char*key) {
  node **t = &root;
  while(1) {
    switch(compare(key, (*t)->key)) {
    case 1:
      t = &(**t).right;
      break;
    case -1:
      t = &(**t).left;
      break;
    case 0:
      if ((*t)->left == NULL) {
        *t = (*t)->right;
        return;
      }
      if ((*t)->right == NULL) {
        *t = (*t)->left;
        return;
      }
      node **t1=&(*t)->left;
      while(1) {
        if((*t1)->right == NULL) {
          (*t)->key = (*t1)->key;
          (*t)->value = (*t1)->value;
          *t1 = (*t1)->left;
          return;
        }
        t1 = &(*t1)->right;
      }
    }
  }
}
