CLASS ltcl_alloc_rollout DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_rollout.
    DATA mt_sit TYPE zcl_alloc_rollout=>ty_site_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_id     TYPE string
        iv_region TYPE string
        iv_users  TYPE i.

    METHODS empty_sites      FOR TESTING.
    METHODS split_by_cap     FOR TESTING.
    METHODS packs_when_small FOR TESTING.
    METHODS splits_by_region FOR TESTING.
    METHODS oversized_alone  FOR TESTING.
    METHODS counts_waves     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_rollout IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_rollout( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_site TYPE zcl_alloc_rollout=>ty_site.

    ls_site-site_id = iv_id.
    ls_site-region = iv_region.
    ls_site-users = iv_users.
    APPEND ls_site TO mt_sit.
  ENDMETHOD.

  METHOD empty_sites.
    DATA(lt_waves) = mo_cut->plan( it_sites = mt_sit iv_max_users = 100 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_waves ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->wave_count( lt_waves ) exp = 0 ).
  ENDMETHOD.

  METHOD split_by_cap.
    add( iv_id = 'B' iv_region = 'EU' iv_users = 20 ).
    add( iv_id = 'A' iv_region = 'EU' iv_users = 10 ).
    add( iv_id = 'C' iv_region = 'US' iv_users = 5 ).

    DATA(lt_waves) = mo_cut->plan( it_sites = mt_sit iv_max_users = 25 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_waves ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_waves[ 1 ]-wave_no exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_waves[ 1 ]-region exp = 'EU' ).
    cl_abap_unit_assert=>assert_equals( act = lt_waves[ 1 ]-users exp = 20 ).
    cl_abap_unit_assert=>assert_equals( act = lt_waves[ 1 ]-sites exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_waves[ 2 ]-users exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = lt_waves[ 3 ]-region exp = 'US' ).
  ENDMETHOD.

  METHOD packs_when_small.
    add( iv_id = 'B' iv_region = 'EU' iv_users = 20 ).
    add( iv_id = 'A' iv_region = 'EU' iv_users = 10 ).
    add( iv_id = 'C' iv_region = 'US' iv_users = 5 ).

    DATA(lt_waves) = mo_cut->plan( it_sites = mt_sit iv_max_users = 100 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_waves ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_waves[ 1 ]-users exp = 30 ).
    cl_abap_unit_assert=>assert_equals( act = lt_waves[ 1 ]-sites exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_waves[ 2 ]-sites exp = 1 ).
  ENDMETHOD.

  METHOD splits_by_region.
    add( iv_id = 'A' iv_region = 'EU' iv_users = 10 ).
    add( iv_id = 'C' iv_region = 'US' iv_users = 5 ).

    DATA(lt_waves) = mo_cut->plan( it_sites = mt_sit iv_max_users = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_waves ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_waves[ 1 ]-region exp = 'EU' ).
    cl_abap_unit_assert=>assert_equals( act = lt_waves[ 2 ]-region exp = 'US' ).
  ENDMETHOD.

  METHOD oversized_alone.
    add( iv_id = 'X' iv_region = 'EU' iv_users = 200 ).
    add( iv_id = 'Y' iv_region = 'EU' iv_users = 10 ).

    DATA(lt_waves) = mo_cut->plan( it_sites = mt_sit iv_max_users = 100 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_waves ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_waves[ 1 ]-users exp = 200 ).
    cl_abap_unit_assert=>assert_equals( act = lt_waves[ 1 ]-sites exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_waves[ 2 ]-users exp = 10 ).
  ENDMETHOD.

  METHOD counts_waves.
    add( iv_id = 'A' iv_region = 'EU' iv_users = 10 ).
    add( iv_id = 'C' iv_region = 'US' iv_users = 5 ).

    DATA(lt_waves) = mo_cut->plan( it_sites = mt_sit iv_max_users = 100 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->wave_count( lt_waves ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
