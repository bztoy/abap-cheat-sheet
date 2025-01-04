CLASS zcl_abap_sample_role_and_user DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES ty_r_agr_name TYPE RANGE OF agr_name.
    TYPES ty_r_uname TYPE RANGE OF uname.
    TYPES:
      BEGIN OF ty_user_roles,
        user  TYPE agr_name,
        roles TYPE SORTED TABLE OF agrname WITH UNIQUE KEY table_line,
      END OF ty_user_roles,
      ty_users_roles TYPE SORTED TABLE OF ty_user_roles WITH UNIQUE KEY user.

    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_abap_sample_role_and_user IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA r_result TYPE ty_users_roles.
    DATA lr_uname TYPE ty_r_uname.
    DATA(lr_arg_name) = VALUE ty_r_agr_name(  ).

    lr_uname = VALUE #( ).

    SELECT DISTINCT agr_name, uname FROM agr_users
        INNER JOIN usr02
                ON usr02~bname EQ agr_users~uname
        INTO TABLE @DATA(roles_by_user)
          WHERE agr_name IN @lr_arg_name
            AND uname    IN @lr_uname
            AND from_dat LE @sy-datum
            AND to_dat   GE @sy-datum
            AND ( gltgv  LE @sy-datum OR gltgv = '00000000' )
            AND ( gltgb  GE @sy-datum OR gltgb = '00000000' ).

    LOOP AT roles_by_user INTO DATA(rbu) GROUP BY rbu-uname.
      INSERT VALUE #( user = rbu-uname ) INTO TABLE r_result REFERENCE INTO DATA(user).
      user->roles = VALUE #( FOR g IN GROUP rbu ( g-agr_name ) ).
    ENDLOOP.

    LOOP AT roles_by_user INTO rbu GROUP BY rbu-uname.
      INSERT VALUE #( user = rbu-uname ) INTO TABLE r_result REFERENCE INTO user.
      LOOP AT GROUP rbu INTO DATA(role).
        INSERT role-agr_name INTO TABLE user->roles.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
