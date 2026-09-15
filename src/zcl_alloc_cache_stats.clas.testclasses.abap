CLASS ltcl_alloc_cache_stats DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cache_stats.

    METHODS setup.

    METHODS counts_hits_misses FOR TESTING.
    METHODS rate_is_zero       FOR TESTING.
    METHODS rate_rounded       FOR TESTING.
    METHODS reset_clears       FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_cache_stats IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cache_stats( ).
  ENDMETHOD.

  METHOD counts_hits_misses.
    mo_cut->note_hit( ).
    mo_cut->note_hit( ).
    mo_cut->note_miss( ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->hits( ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->misses( ) exp = 1 ).
  ENDMETHOD.

  METHOD rate_is_zero.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->hit_rate( ) exp = 0 ).
  ENDMETHOD.

  METHOD rate_rounded.
    mo_cut->note_hit( ).
    mo_cut->note_hit( ).
    mo_cut->note_hit( ).
    mo_cut->note_miss( ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->hit_rate( ) exp = 75 ).
  ENDMETHOD.

  METHOD reset_clears.
    mo_cut->note_hit( ).

    mo_cut->reset( ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->hits( ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->hit_rate( ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
