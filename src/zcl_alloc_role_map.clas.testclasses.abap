CLASS ltcl_alloc_role_map DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_role_map.

    METHODS setup.

    METHODS assigns_role       FOR TESTING.
    METHODS deduplicates       FOR TESTING.
    METHODS lists_roles        FOR TESTING.
    METHODS unknown_user_none  FOR TESTING.
    METHODS counts_assignments FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_role_map IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_role_map( ).
  ENDMETHOD.

  METHOD assigns_role.
    DATA lv_has TYPE abap_bool.

    mo_cut->grant( iv_user = 'LARS' iv_role = 'ALLOCATOR' ).

    lv_has = mo_cut->has_role( iv_user = 'LARS' iv_role = 'ALLOCATOR' ).

    cl_abap_unit_assert=>assert_equals( act = lv_has exp = abap_true ).
  ENDMETHOD.

  METHOD deduplicates.
    mo_cut->grant( iv_user = 'LARS' iv_role = 'ALLOCATOR' ).
    mo_cut->grant( iv_user = 'LARS' iv_role = 'ALLOCATOR' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 1 ).
  ENDMETHOD.

  METHOD lists_roles.
    DATA lt_roles TYPE zcl_alloc_role_map=>ty_role_tt.

    mo_cut->grant( iv_user = 'LARS' iv_role = 'ALLOCATOR' ).
    mo_cut->grant( iv_user = 'LARS' iv_role = 'AUDITOR' ).
    mo_cut->grant( iv_user = 'ANNA' iv_role = 'ALLOCATOR' ).

    lt_roles = mo_cut->roles_of( 'LARS' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_roles ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_roles[ 1 ] exp = 'ALLOCATOR' ).
    cl_abap_unit_assert=>assert_equals( act = lt_roles[ 2 ] exp = 'AUDITOR' ).
  ENDMETHOD.

  METHOD unknown_user_none.
    DATA lt_roles TYPE zcl_alloc_role_map=>ty_role_tt.

    mo_cut->grant( iv_user = 'LARS' iv_role = 'ALLOCATOR' ).

    lt_roles = mo_cut->roles_of( 'ANNA' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_roles ) exp = 0 ).
  ENDMETHOD.

  METHOD counts_assignments.
    mo_cut->grant( iv_user = 'LARS' iv_role = 'ALLOCATOR' ).
    mo_cut->grant( iv_user = 'ANNA' iv_role = 'ALLOCATOR' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
