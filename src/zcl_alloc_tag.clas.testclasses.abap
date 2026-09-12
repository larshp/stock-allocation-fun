CLASS ltcl_alloc_tag DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_tag.

    METHODS setup.

    METHODS tag
      IMPORTING
        iv_run_id     TYPE zstock_run_id
        iv_tag        TYPE c
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_tag=>ty_tag.

    METHODS add_input
      IMPORTING
        it_tags       TYPE zcl_alloc_tag=>ty_tag_tt
        iv_run_id     TYPE zstock_run_id
        iv_tag        TYPE c
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_tag=>ty_add_input.

    METHODS add_new           FOR TESTING.
    METHODS duplicate_ignored FOR TESTING.
    METHODS same_tag_other_run FOR TESTING.
    METHODS of_run_filters    FOR TESTING.
    METHODS empty_list        FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_tag IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_tag( ).
  ENDMETHOD.

  METHOD tag.
    rs_row-run_id = iv_run_id.
    rs_row-tag = iv_tag.
  ENDMETHOD.

  METHOD add_input.
    rs_row-tags = it_tags.
    rs_row-run_id = iv_run_id.
    rs_row-tag = iv_tag.
  ENDMETHOD.

  METHOD add_new.
    DATA lt_tags  TYPE zcl_alloc_tag=>ty_tag_tt.
    DATA ls_input TYPE zcl_alloc_tag=>ty_add_input.

    ls_input = add_input( it_tags   = lt_tags
                          iv_run_id = 'R1'
                          iv_tag    = 'URGENT' ).

    DATA(lt_new) = mo_cut->add( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_new ) exp = 1 ).
  ENDMETHOD.

  METHOD duplicate_ignored.
    DATA lt_tags  TYPE zcl_alloc_tag=>ty_tag_tt.
    DATA ls_input TYPE zcl_alloc_tag=>ty_add_input.

    APPEND tag( iv_run_id = 'R1' iv_tag = 'URGENT' ) TO lt_tags.

    ls_input = add_input( it_tags   = lt_tags
                          iv_run_id = 'R1'
                          iv_tag    = 'URGENT' ).

    DATA(lt_new) = mo_cut->add( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_new ) exp = 1 ).
  ENDMETHOD.

  METHOD same_tag_other_run.
    DATA lt_tags  TYPE zcl_alloc_tag=>ty_tag_tt.
    DATA ls_input TYPE zcl_alloc_tag=>ty_add_input.

    APPEND tag( iv_run_id = 'R1' iv_tag = 'URGENT' ) TO lt_tags.

    ls_input = add_input( it_tags   = lt_tags
                          iv_run_id = 'R2'
                          iv_tag    = 'URGENT' ).

    DATA(lt_new) = mo_cut->add( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_new ) exp = 2 ).
  ENDMETHOD.

  METHOD of_run_filters.
    DATA lt_tags  TYPE zcl_alloc_tag=>ty_tag_tt.
    DATA ls_query TYPE zcl_alloc_tag=>ty_query.

    APPEND tag( iv_run_id = 'R1' iv_tag = 'A' ) TO lt_tags.
    APPEND tag( iv_run_id = 'R2' iv_tag = 'B' ) TO lt_tags.
    APPEND tag( iv_run_id = 'R1' iv_tag = 'C' ) TO lt_tags.

    ls_query-tags = lt_tags.
    ls_query-run_id = 'R1'.

    DATA(lt_found) = mo_cut->of_run( ls_query ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_found ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_found[ 1 ]-tag exp = 'A' ).
    cl_abap_unit_assert=>assert_equals( act = lt_found[ 2 ]-tag exp = 'C' ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_tags  TYPE zcl_alloc_tag=>ty_tag_tt.
    DATA ls_query TYPE zcl_alloc_tag=>ty_query.

    ls_query-run_id = 'R1'.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->of_run( ls_query ) ).
  ENDMETHOD.

ENDCLASS.
