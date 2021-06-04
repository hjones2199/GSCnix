{
  description = "A flake to build and install the Guide Star Catalog";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;

  outputs = { self, nixpkgs }: {
    defaultPackage.x86_64-linux =
      with import nixpkgs { system = "x86_64-linux"; };
        stdenv.mkDerivation rec {
          pname = "GSC";
          version = "1.2";

          src = fetchurl {
            url = "http://cdsarc.u-strasbg.fr/viz-bin/nph-Cat/tar.gz?bincats/${pname}_${version}";
            sha256 = "sha256-SC9Wxwj3r0cfBxFQL7Nc5sbRyNDNyJ1wwahzUdjgyZ4=";
          };

          unpackPhase = ''
            runHook preUnpack
            mkdir ${pname}-${version}
            tar -C ${pname}-${version} -xzf $src
            runHook postUnpack
          '';

          postUnpack = ''
            cd ${pname}-${version}/src
          '';

          postPatch = ''
            substituteInPlace Makefile --replace genreg.exe ./genreg.exe
          '';

          hardeningDisable = [ "fortify" ];

          buildPhase = ''
            make default genreg.exe
          '';

          installPhase = ''
            mkdir -p $out/share/GSC/bin
            mkdir $out/bin
            cp gsc.exe $out/share/GSC/bin/gsc
            cp decode.exe $out/share/GSC/bin/decode
            cp -r ../N* $out/share/GSC
            cp -r ../S* $out/share/GSC
            GSCDAT=$out/share/GSC ./genreg.exe -b -c -d
            ln -s $out/share/GSC/bin/* $out/bin
          '';

          meta = with lib; {
            description = "Catalog of guide stars to assist in pointing astronomy devices";
            homepage = "https://gsss.stsci.edu/Catalogs/GSC/GSC1/GSC1.htm";
            maintainers = with maintainers; [ hjones2199 ];
            license = licenses.mit;
            platforms = platforms.unix;
          };
        };
  };
}
