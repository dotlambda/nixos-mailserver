#  nixos-mailserver: a simple mail server
#  Copyright (C) 2016-2017  Robin Raymond
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program. If not, see <http://www.gnu.org/licenses/>

{ config, pkgs, lib, ... }:

with config.mailserver;

let
  vmail_user = [{
    name = vmailUserName;
    isNormalUser = false;
    uid = vmailUIDStart;
    home = mailDirectory;
    createHome = true;
    group = vmailGroupName;
  }];

  # accountsToUser :: String -> UserRecord
  accountsToUser = account: {
    name = account.name + "@" + domain;
    isNormalUser = false;
    group = vmailGroupName;
    inherit (account) hashedPassword;
  };

  # mail_user :: [ UserRecord ]
  mail_user = map accountsToUser (lib.attrValues loginAccounts);

in
{

  config = lib.mkIf enable {
    # set the vmail gid to a specific value
    users.groups = {
      vmail = { gid = vmailUIDStart; };
    };

    # define all users
    users.extraUsers = vmail_user ++ mail_user;
  };
}
