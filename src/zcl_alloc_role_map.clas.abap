CLASS zcl_alloc_role_map DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_user TYPE c LENGTH 12.
    TYPES ty_role TYPE c LENGTH 20.

    TYPES: BEGIN OF ty_assignment,
             user TYPE ty_user,
             role TYPE ty_role,
           END OF ty_assignment.
    TYPES ty_assignment_tt TYPE STANDARD TABLE OF ty_assignment WITH DEFAULT KEY.
    TYPES ty_role_tt       TYPE STANDARD TABLE OF ty_role WITH DEFAULT KEY.

    METHODS grant
      IMPORTING
        iv_user TYPE ty_user
        iv_role TYPE ty_role.

    METHODS has_role
      IMPORTING
        iv_user       TYPE ty_user
        iv_role       TYPE ty_role
      RETURNING
        VALUE(rv_has) TYPE abap_bool.

    METHODS roles_of
      IMPORTING
        iv_user         TYPE ty_user
      RETURNING
        VALUE(rt_roles) TYPE ty_role_tt.

    METHODS count
      RETURNING
        VALUE(rv_count) TYPE i.

  PRIVATE SECTION.
    DATA mt_assignments TYPE ty_assignment_tt.

ENDCLASS.


CLASS zcl_alloc_role_map IMPLEMENTATION.

  METHOD grant.
    DATA ls_assignment TYPE ty_assignment.

    READ TABLE mt_assignments INTO ls_assignment
      WITH KEY user = iv_user role = iv_role.

    IF sy-subrc <> 0.
      ls_assignment-user = iv_user.
      ls_assignment-role = iv_role.
      APPEND ls_assignment TO mt_assignments.
    ENDIF.
  ENDMETHOD.

  METHOD has_role.
    DATA ls_assignment TYPE ty_assignment.

    READ TABLE mt_assignments INTO ls_assignment
      WITH KEY user = iv_user role = iv_role.

    IF sy-subrc = 0.
      rv_has = abap_true.
    ELSE.
      rv_has = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD roles_of.
    DATA ls_assignment TYPE ty_assignment.

    LOOP AT mt_assignments INTO ls_assignment.
      IF ls_assignment-user = iv_user.
        APPEND ls_assignment-role TO rt_roles.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD count.
    rv_count = lines( mt_assignments ).
  ENDMETHOD.

ENDCLASS.
