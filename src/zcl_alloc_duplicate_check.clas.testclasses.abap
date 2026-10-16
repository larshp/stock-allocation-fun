CLASS ltcl_alloc_duplicate_check DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_duplicate_check.

    METHODS setup.

    METHODS add
      IMPORTING
        it_reqs        TYPE zif_requirement_reader=>ty_requirement_tt
        iv_id          TYPE zif_requirement_reader=>ty_requirement-id
      RETURNING
        VALUE(rt_reqs) TYPE zif_requirement_reader=>ty_requirement_tt.

    METHODS empty_list      FOR TESTING.
    METHODS unique_ids      FOR TESTING.
    METHODS duplicate_pair  FOR TESTING.
    METHODS triplicate      FOR TESTING.
    METHODS two_groups      FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_duplicate_check IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_duplicate_check( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_row TYPE zif_requirement_reader=>ty_requirement.

    rt_reqs = it_reqs.
    ls_row-id = iv_id.
    APPEND ls_row TO rt_reqs.
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_reqs TYPE zif_requirement_reader=>ty_requirement_tt.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->find( lt_reqs ) ).
  ENDMETHOD.

  METHOD unique_ids.
    DATA lt_reqs TYPE zif_requirement_reader=>ty_requirement_tt.

    lt_reqs = add( it_reqs = lt_reqs iv_id = 'REQ-1' ).
    lt_reqs = add( it_reqs = lt_reqs iv_id = 'REQ-2' ).

    cl_abap_unit_assert=>assert_initial( act = mo_cut->find( lt_reqs ) ).
  ENDMETHOD.

  METHOD duplicate_pair.
    DATA lt_reqs TYPE zif_requirement_reader=>ty_requirement_tt.

    lt_reqs = add( it_reqs = lt_reqs iv_id = 'REQ-1' ).
    lt_reqs = add( it_reqs = lt_reqs iv_id = 'REQ-1' ).

    DATA(lt_dups) = mo_cut->find( lt_reqs ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_dups ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_dups[ 1 ]-id exp = 'REQ-1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_dups[ 1 ]-count exp = 2 ).
  ENDMETHOD.

  METHOD triplicate.
    DATA lt_reqs TYPE zif_requirement_reader=>ty_requirement_tt.

    lt_reqs = add( it_reqs = lt_reqs iv_id = 'REQ-1' ).
    lt_reqs = add( it_reqs = lt_reqs iv_id = 'REQ-1' ).
    lt_reqs = add( it_reqs = lt_reqs iv_id = 'REQ-1' ).

    DATA(lt_dups) = mo_cut->find( lt_reqs ).

    cl_abap_unit_assert=>assert_equals( act = lt_dups[ 1 ]-count exp = 3 ).
  ENDMETHOD.

  METHOD two_groups.
    DATA lt_reqs TYPE zif_requirement_reader=>ty_requirement_tt.

    lt_reqs = add( it_reqs = lt_reqs iv_id = 'REQ-2' ).
    lt_reqs = add( it_reqs = lt_reqs iv_id = 'REQ-1' ).
    lt_reqs = add( it_reqs = lt_reqs iv_id = 'REQ-2' ).
    lt_reqs = add( it_reqs = lt_reqs iv_id = 'REQ-1' ).

    DATA(lt_dups) = mo_cut->find( lt_reqs ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_dups ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_dups[ 1 ]-id exp = 'REQ-1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_dups[ 2 ]-id exp = 'REQ-2' ).
  ENDMETHOD.

ENDCLASS.
