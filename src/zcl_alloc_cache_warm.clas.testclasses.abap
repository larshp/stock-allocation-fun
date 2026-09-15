CLASS ltcl_alloc_cache_warm DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cache_warm.

    METHODS setup.

    METHODS finds_missing        FOR TESTING.
    METHODS no_missing_when_warm FOR TESTING.
    METHODS counts_cached        FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_cache_warm IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cache_warm( ).
  ENDMETHOD.

  METHOD finds_missing.
    DATA lt_cached  TYPE zcl_alloc_cache_warm=>ty_key_tt.
    DATA lt_wanted  TYPE zcl_alloc_cache_warm=>ty_key_tt.
    DATA lv_key     TYPE zcl_alloc_cache_warm=>ty_key.
    DATA lt_missing TYPE zcl_alloc_cache_warm=>ty_key_tt.

    lv_key = 'A'.
    APPEND lv_key TO lt_cached.

    lv_key = 'B'.
    APPEND lv_key TO lt_cached.

    lv_key = 'B'.
    APPEND lv_key TO lt_wanted.

    lv_key = 'C'.
    APPEND lv_key TO lt_wanted.

    lt_missing = mo_cut->missing( it_cached = lt_cached it_wanted = lt_wanted ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_missing ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_missing[ 1 ] exp = 'C' ).
  ENDMETHOD.

  METHOD no_missing_when_warm.
    DATA lt_cached  TYPE zcl_alloc_cache_warm=>ty_key_tt.
    DATA lt_wanted  TYPE zcl_alloc_cache_warm=>ty_key_tt.
    DATA lv_key     TYPE zcl_alloc_cache_warm=>ty_key.
    DATA lt_missing TYPE zcl_alloc_cache_warm=>ty_key_tt.

    lv_key = 'A'.
    APPEND lv_key TO lt_cached.
    APPEND lv_key TO lt_wanted.

    lt_missing = mo_cut->missing( it_cached = lt_cached it_wanted = lt_wanted ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_missing ) exp = 0 ).
  ENDMETHOD.

  METHOD counts_cached.
    DATA lt_cached TYPE zcl_alloc_cache_warm=>ty_key_tt.
    DATA lt_wanted TYPE zcl_alloc_cache_warm=>ty_key_tt.
    DATA lv_key    TYPE zcl_alloc_cache_warm=>ty_key.
    DATA lv_count  TYPE i.

    lv_key = 'A'.
    APPEND lv_key TO lt_cached.
    APPEND lv_key TO lt_wanted.

    lv_key = 'B'.
    APPEND lv_key TO lt_wanted.

    lv_count = mo_cut->cached_count( it_cached = lt_cached it_wanted = lt_wanted ).

    cl_abap_unit_assert=>assert_equals( act = lv_count exp = 1 ).
  ENDMETHOD.

ENDCLASS.
