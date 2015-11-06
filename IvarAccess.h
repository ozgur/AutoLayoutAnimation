//
//  IvarAccess.h
//
//  Generic access to get/set ivars - functions so they work with Swift.
//
//  $Id: //depot/XprobePlugin/Classes/IvarAccess.h#37 $
//
//  Source Repo:
//  https://github.com/johnno1962/Xprobe/blob/master/Classes/IvarAccess.h
//
//  Created by John Holdsworth on 16/05/2015.
//  Copyright (c) 2015 John Holdsworth. All rights reserved.
//

/*
 
 This file has the MIT License (MIT)
 
 Copyright (c) 2015 John Holdsworth
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 */

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wreserved-id-macro"
#pragma clang diagnostic ignored "-Wold-style-cast"
#pragma clang diagnostic ignored "-Wcstring-format-directive"
#pragma clang diagnostic ignored "-Wgnu-conditional-omitted-operand"
#pragma clang diagnostic ignored "-Wcast-align"
#pragma clang diagnostic ignored "-Wmissing-noreturn"
#pragma clang diagnostic ignored "-Wunused-exception-parameter"
#pragma clang diagnostic ignored "-Wc11-extensions"
#pragma clang diagnostic ignored "-Wvla-extension"
#pragma clang diagnostic ignored "-Wvla"

#ifndef _IvarAccess_h
#define _IvarAccess_h

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

extern const char *ivar_getTypeEncodingSwift( Ivar ivar, Class aClass );
extern Class ivar_getObjectTypeSwift( Ivar ivar, Class aClass );

NSString *utf8String( const char *chars ) {
  return chars ? [NSString stringWithUTF8String:chars] : @"";
}

#pragma mark ivar_getTypeEncoding() for swift

// From Jay Freeman's https://www.youtube.com/watch?v=Ii-02vhsdVk

struct _swift_data {
  unsigned long flags;
  const char *className;
  int fieldcount, flags2;
  const char *ivarNames;
  struct _swift_field **(*get_field_data)();
};

struct _swift_class {
  union {
    Class meta;
    unsigned long flags;
  };
  Class supr;
  void *buckets, *vtable, *pdata;
  int f1, f2; // added for Beta5
  int size, tos, mdsize, eight;
  struct _swift_data *swiftData;
  IMP dispatch[1];
};

struct _swift_field {
  union {
    Class meta;
    unsigned long flags;
  };
  union {
    struct _swift_field *typeInfo;
    const char *typeIdent;
    Class objcClass;
  };
  void *unknown;
  struct _swift_field *optional;
};

static struct _swift_class *isSwift( Class aClass ) {
  struct _swift_class *swiftClass = (__bridge struct _swift_class *)aClass;
  return (uintptr_t)swiftClass->pdata & 0x1 ? swiftClass : NULL;
}

static const char *strfmt( NSString *fmt, ... ) NS_FORMAT_FUNCTION(1,2);
static const char *strfmt( NSString *fmt, ... ) {
  va_list argp;
  va_start(argp, fmt);
  return [[[NSString alloc] initWithFormat:fmt arguments:argp] UTF8String];
}

static const char *typeInfoForClass( Class aClass, const char *optionals ) {
  return strfmt( @"@\"%@\"%s", NSStringFromClass( aClass ), optionals );
}

static const char *skipSwift( const char *typeIdent ) {
  while ( isalpha( *typeIdent ) )
    typeIdent++;
  while ( isnumber( *typeIdent ) )
    typeIdent++;
  return typeIdent;
}

Class ivar_getObjectTypeSwift( Ivar ivar, Class aClass ) {
  struct _swift_class *swiftClass = isSwift( aClass );
  if ( !swiftClass )
    return NULL;
  
  struct _swift_data *swiftData = swiftClass->swiftData;
  const char *nameptr = swiftData->ivarNames;
  const char *name = ivar_getName(ivar);
  int ivarIndex;
  
  for ( ivarIndex=0 ; ivarIndex < swiftData->fieldcount ; ivarIndex++ )
    if ( strcmp( name, nameptr ) == 0 )
      break;
    else
      nameptr += strlen(nameptr)+1;
  
  if ( ivarIndex >= swiftData->fieldcount )
    return NULL;
  
  struct _swift_field *field0 = swiftData->get_field_data()[ivarIndex], *field = field0;
  char optionals[100] = "", *optr = optionals;
  
  // unwrap any optionals
  while ( field->flags == 0x2 ) {
    if ( field->optional ) {
      field = field->optional;
      *optr++ = '?';
      *optr = '\000';
    }
    else
      return NULL;
  }
  
  if ( field->flags == 0x1 ) { // rawtype
    return NULL;
  }
  else if ( field->flags == 0xa ) // function
    return NULL;
  else if ( field->flags == 0xc ) // protocol
    return NULL;
  else if ( field->flags == 0xe ) // objc class
    return field->objcClass;
  else if ( field->flags == 0x10 ) // pointer
    return NULL;
  else if ( (field->flags & 0xff) == 0x55 ) // enum?
    return NULL;
  else if ( field->flags < 0x100 || field->flags & 0x3 ) // unknown/bad isa
    return NULL;
  else // swift class
    return (__bridge Class)field;
  return NULL;
}

// returned type string has "autorelease" scope
const char *ivar_getTypeEncodingSwift( Ivar ivar, Class aClass ) {
  struct _swift_class *swiftClass = isSwift( aClass );
  if ( !swiftClass )
    return ivar_getTypeEncoding( ivar );
  
  struct _swift_data *swiftData = swiftClass->swiftData;
  const char *nameptr = swiftData->ivarNames;
  const char *name = ivar_getName(ivar);
  int ivarIndex;
  
  for ( ivarIndex=0 ; ivarIndex < swiftData->fieldcount ; ivarIndex++ )
    if ( strcmp( name, nameptr ) == 0 )
      break;
    else
      nameptr += strlen(nameptr)+1;
  
  if ( ivarIndex >= swiftData->fieldcount )
    return NULL;
  
  struct _swift_field *field0 = swiftData->get_field_data()[ivarIndex], *field = field0;
  char optionals[100] = "", *optr = optionals;
  
  // unwrap any optionals
  while ( field->flags == 0x2 ) {
    if ( field->optional ) {
      field = field->optional;
      *optr++ = '?';
      *optr = '\000';
    }
    else
      return strfmt( @"%s%s", field->typeInfo->typeIdent, optionals );
  }
  
  if ( field->flags == 0x1 ) { // rawtype
    const char *typeIdent = field->typeInfo->typeIdent;
    if ( typeIdent[0] == 'V' ) {
      if ( typeIdent[1] == 'S' && (typeIdent[2] == 'C' || typeIdent[2] == 's') )
        return strfmt( @"{%@}%s#%s", utf8String( skipSwift( typeIdent ) ), optionals, typeIdent );
      else
        return strfmt( @"{%@}%s#%s", utf8String( skipSwift( skipSwift( typeIdent ) ) ), optionals, typeIdent );
    }
    else
      return strfmt( @"%s%s", field->typeInfo->typeIdent, optionals )+1;
  }
  else if ( field->flags == 0xa ) // function
    return strfmt( @"^{Block}%s", optionals );
  else if ( field->flags == 0xc ) // protocol
    return strfmt( @"@\"<%@>\"%s", utf8String( field->optional->typeIdent ), optionals );
  else if ( field->flags == 0xe ) // objc class
    return typeInfoForClass( field->objcClass, optionals );
  else if ( field->flags == 0x10 ) // pointer
    return strfmt( @"^{%@}%s", utf8String( skipSwift( field->typeIdent ?: "??" ) ), optionals );
  else if ( (field->flags & 0xff) == 0x55 ) // enum?
    return strfmt( @"e%s", optionals );
  else if ( field->flags < 0x100 || field->flags & 0x3 ) // unknown/bad isa
    return strfmt( @"?FLAGS#%lx(%p)%s", field->flags, field, optionals );
  else // swift class
    return typeInfoForClass( (__bridge Class)field, optionals );
}

#endif
#pragma clang diagnostic pop