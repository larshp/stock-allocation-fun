CLASS ltcl_alloc_req_merge DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_req_merge.

    METHODS setup.

    METHODS requirement
      IMPORTING
        iv_id         TYPE zif_requirement_reader=>ty_requirement-id
        iv_qty        TYPE menge_d
        iv_priority   TYPE i
      RETURNING
        VALUE(rs_row) TYPE zif_requirement_reader=>ty_requirement.

    METHODS empty_list      FOR TESTING.
    METHODS single_entry    FOR TESTING.
    METHODS two_merged      FOR TESTING.
    METHODS three_merged    FOR TESTING.
    METHODS different_ids   FOR TESTING.
    METHODS keeps_first_key FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_req_merge IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_req_merge( ).
  ENDMETHOD.

  METHOD requirement.
    rs_row-id = iv_id.
    rs_row-requested_qty = iv_qty.
    rs_row-priority = iv_priority.
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_reqs TYPE zif_requirement_reader=>ty_requirement_tt.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->merge( lt_reqs ) ).
  ENDMETHOD.

  METHOD single_entry.
    DATA lt_reqs TYPE zif_requirement_reader=>ty_requirement_tt.

    APPEND requirement( iv_id = 'REQ-1' iv_qty = '10' iv_priority = 1 )
      TO lt_reqs.

    DATA(lt_merged) = mo_cut->merge( lt_reqs ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_merged ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_merged[ 1 ]-requested_qty
                                        exp = '10' ).
  ENDMETHOD.

  METHOD two_merged.
    DATA lt_reqs TYPE zif_requirement_reader=>ty_requirement_tt.

    APPEND requirement( iv_id = 'REQ-1' iv_qty = '10' iv_priority = 1 )
      TO lt_reqs.
    APPEND requirement( iv_id = 'REQ-1' iv_qty = '5' iv_priority = 1 )
      TO lt_reqs.

    DATA(lt_merged) = mo_cut->merge( lt_reqs ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_merged ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_merged[ 1 ]-requested_qty
                                        exp = '15' ).
  ENDMETHOD.

  METHOD three_merged.
    DATA lt_reqs TYPE zif_requirement_reader=>ty_requirement_tt.

    APPEND requirement( iv_id = 'REQ-1' iv_qty = '10' iv_priority = 1 )
      TO lt_reqs.
    APPEND requirement( iv_id = 'REQ-1' iv_qty = '5' iv_priority = 1 )
      TO lt_reqs.
    APPEND requirement( iv_id = 'REQ-1' iv_qty = '2' iv_priority = 1 )
      TO lt_reqs.

    DATA(lt_merged) = mo_cut->merge( lt_reqs ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_merged ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_merged[ 1 ]-requested_qty
                                        exp = '17' ).
  ENDMETHOD.

  METHOD different_ids.
    DATA lt_reqs TYPE zif_requirement_reader=>ty_requirement_tt.

    APPEND requirement( iv_id = 'REQ-2' iv_qty = '10' iv_priority = 1 )
      TO lt_reqs.
    APPEND requirement( iv_id = 'REQ-1' iv_qty = '5' iv_priority = 1 )
      TO lt_reqs.

    DATA(lt_merged) = mo_cut->merge( lt_reqs ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_merged ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_merged[ 1 ]-id exp = 'REQ-1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_merged[ 2 ]-id exp = 'REQ-2' ).
  ENDMETHOD.

  METHOD keeps_first_key.
    DATA lt_reqs TYPE zif_requirement_reader=>ty_requirement_tt.

    APPEND requirement( iv_id = 'REQ-1' iv_qty = '10' iv_priority = 3 )
      TO lt_reqs.
    APPEND requirement( iv_id = 'REQ-1' iv_qty = '5' iv_priority = 9 )
      TO lt_reqs.

    DATA(lt_merged) = mo_cut->merge( lt_reqs ).

    cl_abap_unit_assert=>assert_equals( act = lt_merged[ 1 ]-priority exp = 3 ).
  ENDMETHOD.

ENDCLASS.
