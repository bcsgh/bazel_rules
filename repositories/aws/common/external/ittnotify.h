#ifndef _ITTNOTIFY_H_
#define _ITTNOTIFY_H_

#include <stddef.h>

/*
 * Minimal stubs needed to make some stuff that uses the compile.
 */

#define ITTAPI

typedef struct ___itt_domain
{
} __itt_domain;

static __itt_domain* ITTAPI __itt_domain_create(const void * unused) { return NULL; }

typedef struct ___itt_id
{
} __itt_id;

static const __itt_id __itt_null = {};

typedef struct ___itt_string_handle
{
} __itt_string_handle;

static __itt_string_handle* ITTAPI __itt_string_handle_create(const void *name) { return NULL; }
static void ITTAPI __itt_task_begin(const __itt_domain *domain, __itt_id taskid, __itt_id parentid, __itt_string_handle *name) {}
static void ITTAPI __itt_task_end(const __itt_domain *domain) {}

#endif /* _ITTNOTIFY_H_ */
