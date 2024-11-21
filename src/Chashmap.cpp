#include <unordered_map>
#include <R.h>
#include <Rinternals.h>
#include <string.h>
#include <stdint.h> 

#ifndef R_NO_REMAP
#define R_NO_REMAP
#endif 

#define GET_MAP_PTR(SEXP) static_cast<C_map*>(R_ExternalPtrAddr(SEXP))

#define CONV_SEXP_PROTECTED(n, conv) do {       \
    switch((n).type) {                       \
        case INTSXP:                     \
            conv = PROTECT(Rf_ScalarInteger((n).val.intVal)); \
            break;                       \
        case STRSXP:                     \
            conv = PROTECT(Rf_mkString((n).val.charVal));     \
            break;                       \
        case REALSXP:                    \
            conv = PROTECT(Rf_ScalarReal((n).val.doubleVal)); \
            break;                       \
        default:                         \
            conv = R_NilValue;            \
            break;                       \
    } \
} while (0) \

extern "C" {

typedef union node_value {
    int intVal;
    double doubleVal;
    const char* charVal;
} node_value;

typedef struct node {
    int type;
    node_value val;
} node;

// comparator
struct map_eq {
    bool operator()(node o1, node o2) const {
        if (o1.type != o2.type) return 0;

        switch (o1.type) {
            case REALSXP: return (o2.val.doubleVal == o1.val.doubleVal);
            case INTSXP: return (o2.val.intVal == o1.val.intVal);
            case STRSXP : return !(strcmp(o2.val.charVal, o1.val.charVal));
            default : return 0;
        }
    }
};

// convert elements of vector into node vector
node* get_vals(SEXP vec) {
    R_len_t len = LENGTH(vec);
    node* n = (node*) R_alloc(len, sizeof(node));

    if (TYPEOF(vec) == REALSXP) {
        double* vals = REAL(vec);
        for (R_len_t i = 0; i < len; i++) {
            n[i] = {REALSXP, {.doubleVal = vals[i]}};
        }
    } else if (TYPEOF(vec) == INTSXP) {
        int* vals = INTEGER(vec);
         for (R_len_t i = 0; i < len; i++) {
            n[i] = {INTSXP, {.intVal = vals[i]}};
        }
    } else if (TYPEOF(vec) == STRSXP) {
        for (R_len_t i = 0; i < len; i++) {
            n[i] = {STRSXP, {.charVal = CHAR(STRING_ELT(vec, i))}};
        }
    }
    return n;
}

// https://gist.github.com/sgsfak/9ba382a0049f6ee885f68621ae86079b
std::size_t str_hash(const char* str) {
    unsigned char *cur = (unsigned char*)str; 
    const uint32_t FNV_32_PRIME = 0x01000193; 

    uint32_t h = 0x811c9dc5; 
    while (*cur) {
        h^= *cur++;
        h *= FNV_32_PRIME;
    }
    return h; 
}

// hash function
struct map_hash {
    std::size_t operator()(const node &n) const {
        switch (n.type) {
            case REALSXP: return std::hash<long>()(static_cast<long>(n.val.doubleVal));
            case INTSXP: return std::hash<int>()(n.val.intVal);
            case STRSXP: str_hash(n.val.charVal);
            default: return 0;
        }
    }
};

using C_map = std::unordered_map<node, node, map_hash, map_eq>;

// called by garbage collector to free hahsmap
void C_hashmap_finalize(SEXP map){
    C_map *c_map = GET_MAP_PTR(map);
    delete c_map;
}

// initialize empty hashmap
SEXP C_hashmap_init() {
    C_map *c_map = new C_map;
    SEXP c_map_extptr = PROTECT(R_MakeExternalPtr(c_map, R_NilValue, R_NilValue));
    R_RegisterCFinalizerEx(c_map_extptr, C_hashmap_finalize, TRUE);
    setAttrib(c_map_extptr, R_ClassSymbol, mkString("C_hashmap"));
    UNPROTECT(1);
    return c_map_extptr;
}

SEXP C_hashmap_insert(SEXP map, SEXP k, SEXP v) {

    C_map *c_map = GET_MAP_PTR(map);

    R_len_t len = LENGTH(k);

    node* vals = get_vals(v);
    node* keys = get_vals(k);

    for (R_len_t i = 0; i < len; i++) {
        c_map->insert_or_assign(keys[i], vals[i]);
    }
    return R_NilValue;
}

SEXP C_hashmap_get(SEXP map, SEXP k) {
    R_len_t len = LENGTH(k);
    SEXP res = PROTECT(Rf_allocVector(VECSXP, len));
    C_map *c_map = GET_MAP_PTR(map);

    node* keys = get_vals(k);

    for (R_len_t i = 0; i < len; i++) {
        auto r = c_map->find(keys[i]);

        if (r != nullptr) {
            SEXP out;
            node n = r->second;
            CONV_SEXP_PROTECTED(n, out);
            SET_VECTOR_ELT(res, i, out);
            UNPROTECT(1);
        } else {
            SET_VECTOR_ELT(res, i, R_NilValue);
        }
    }
    UNPROTECT(1);
    return res;
}

SEXP C_hashmap_remove(SEXP map, SEXP k) {
    C_map *c_map = GET_MAP_PTR(map);

    R_len_t len = LENGTH(k);
    node* vals = get_vals(k);

    for (R_len_t i = 0; i < len; i++) {
        c_map->erase(vals[i]);
    }
    return R_NilValue;
}

SEXP C_hashmap_getkeys(SEXP map) {
    C_map *c_map = GET_MAP_PTR(map);
    SEXP keys = PROTECT(Rf_allocVector(VECSXP, c_map->size()));

    int i = 0;
    for (auto &iter : *c_map) {
            node n = iter.first;
            SEXP out;
            CONV_SEXP_PROTECTED(n, out);
            SET_VECTOR_ELT(keys, i++, out);
            UNPROTECT(1);
    }
    UNPROTECT(1);
    return keys;
}

SEXP C_hashmap_getvals(SEXP map) {
    C_map *c_map = GET_MAP_PTR(map);
    SEXP vals = PROTECT(Rf_allocVector(VECSXP, c_map->size()));

    int i = 0;
    for (auto &iter : *c_map) {
            node n = iter.second;
            SEXP out;
            CONV_SEXP_PROTECTED(n, out);
            SET_VECTOR_ELT(vals, i++, out);
            UNPROTECT(1);
    }
    UNPROTECT(1);
    return vals;
}

// clears map
SEXP C_hashmap_clear(SEXP map) {
    C_map *c_map = GET_MAP_PTR(map);
    c_map->clear();
    return R_NilValue;
}

SEXP C_hashmap_size(SEXP map) {
    C_map *c_map = GET_MAP_PTR(map);
    return Rf_ScalarInteger(c_map->size());
}

}
