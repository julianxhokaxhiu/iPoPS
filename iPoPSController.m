/***********************************************************************************************************

iPoPS is a free tool converson for PSX games that are into CD form or ISO form, and convert it
straight from your CD (or ISO) to an EBOOT compatible for your PSP. Just convert and play, that's all :D
This project was born in a response to "Prometeus" project for Mac, to make it free and opensource to all.

The MIT License (MIT)

Copyright (c) 2013 Julian Xhokaxhiu

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

***********************************************************************************************************/

#import "iPoPSController.h"

@implementation iPoPSController

@synthesize editValue = editValue_;

- (void)openPanelDidEnd:(NSOpenPanel *)openPanel returnCode:(int)rc contextInfo:(void *)ci
{
	if (rc == NSOKButton)
	{
		if (ci == btnDestinationFolder)
		{
			[txtDestinationFolder setStringValue:[openPanel filename]];
			[btnStartTheProcess setEnabled:TRUE];
		}
		else if (ci == btnIconFile) [txtIconFile setStringValue:[openPanel filename]];
		else if (ci == btnAnimatedIconFile) [txtAnimatedIconFile setStringValue:[openPanel filename]];
		else if (ci == btnBackgroundFile) [txtBackgroundFile setStringValue:[openPanel filename]];
		else if (ci == btnSoundFile) [txtSoundFile setStringValue:[openPanel filename]];
		else if (ci == btnSourceISO)
		{
			[txtSourceISO setStringValue:[openPanel filename]];
			[btnDestinationFolder setEnabled:TRUE];
		}
	}
}

- (void) applicationDidFinishLaunching:(NSNotification *) aNotification
{
    deviceList = [[NSMutableArray alloc] initWithCapacity:[[DRDevice devices] count]];

    [[DRNotificationCenter currentRunLoopCenter] addObserver:self selector:@selector(deviceDisappeared:)
														name:DRDeviceDisappearedNotification object:nil];

    [[DRNotificationCenter currentRunLoopCenter] addObserver:self selector:@selector(deviceAppeared:)
														name:DRDeviceAppearedNotification object:nil];

	[self updateMediaStatus];
}

- (void) deviceAppeared:(NSNotification *) aNotification
{
    DRDevice *newDevice = [aNotification object];

    [deviceList addObject:newDevice];

    [[DRNotificationCenter currentRunLoopCenter] addObserver:self selector:@selector(deviceStateChanged:)
														name:DRDeviceStatusChangedNotification object:newDevice];

    [self updateMediaStatus];
}

- (void) deviceDisappeared:(NSNotification *) aNotification
{
    DRDevice *removedDevice = [aNotification object];

    [[DRNotificationCenter currentRunLoopCenter] removeObserver:self name:DRDeviceStatusChangedNotification
														 object:removedDevice];

    [deviceList removeObject:removedDevice];
    [self updateMediaStatus];
}

- (void) deviceStateChanged:(NSNotification *) aNotification
{
    [self updateMediaStatus];
}

- (void)updateMediaStatus
{
	DRDevice *deviceDVDROM;
    NSEnumerator *deviceEnumerator = [deviceList objectEnumerator];

    while ((deviceDVDROM = [deviceEnumerator nextObject]) != nil)
    {
		devDVDROMFound = deviceDVDROM;

        NSDictionary *deviceStatus = [deviceDVDROM status];

        NSString *mediaState = [deviceStatus objectForKey:DRDeviceMediaStateKey];

        if ([mediaState isEqualTo:DRDeviceMediaStateMediaPresent])
        {
            NSDictionary *mediaInfo = [deviceStatus objectForKey:DRDeviceMediaInfoKey];

            mediaType = [mediaInfo objectForKey:DRDeviceMediaTypeKey];
        }
        else if ([mediaState isEqualTo:DRDeviceMediaStateNone])
        {
            mediaType = @"No Disc";
        }
        else
        {
            mediaType = @"In Transition";
        }
    }
}

- (IBAction)SelectDirectory:(id)sender
{
	//Creo la variabile che conterrà il mio dialogo "scegli directory"
    NSOpenPanel* panel = [NSOpenPanel openPanel];

	//Lo configuro per scegliere solo le cartelle
	[panel setCanChooseFiles:NO];
	[panel setCanChooseDirectories:YES];
	[panel setResolvesAliases:YES];
	[panel setAllowsMultipleSelection:NO];

	//Visualizzo la finestra di selezione directory
	[panel beginSheetForDirectory: nil
							 file: nil
							types: nil
				   modalForWindow: [NSApp mainWindow]
					modalDelegate: self
				   didEndSelector: @selector(openPanelDidEnd:returnCode:contextInfo:)
					  contextInfo: sender];
}

- (IBAction)SelectFile:(id)sender
{
	//Creo la variabile che conterrà il mio dialogo "scegli directory" e la variabile di filtro delle estensioni
    NSOpenPanel* panel = [NSOpenPanel openPanel];
	NSArray* typeselected = [NSArray array];

	// Setto il filtro di selezione del file per la finestra di apertura dei file
	if ((sender == btnIconFile) || (sender == btnBackgroundFile) || (sender == btnBootPicture))
		typeselected = [NSArray arrayWithObjects:@"png", @"PNG", @"bmp", @"BMP", @"jpg", @"JPG", @"gif", @"GIF", nil];
	else if (sender == btnAnimatedIconFile)
		typeselected = [NSArray arrayWithObjects:@"pmf", @"PMF", nil];
	else if (sender == btnSoundFile)
		typeselected = [NSArray arrayWithObjects:@"at3", @"AT3", nil];
	else if (sender == btnSourceISO)
		typeselected = [NSArray arrayWithObjects:@"iso", @"ISO", @"bin", @"BIN", @"img", @"IMG", nil];

	//Lo configuro per scegliere solo le cartelle
	[panel setCanChooseFiles:YES];
	[panel setCanChooseDirectories:NO];
	[panel setResolvesAliases:YES];
	[panel setAllowsMultipleSelection:NO];

	//Visualizzo la finestra di selezione directory
	[panel beginSheetForDirectory: nil
							 file: nil
							types: typeselected
				   modalForWindow: [NSApp mainWindow]
					modalDelegate: self
				   didEndSelector: @selector(openPanelDidEnd:returnCode:contextInfo:)
					  contextInfo: sender];
}

- (IBAction)EnableISOSelecting:(id)sender
{
	[txtSourceISO setEnabled:TRUE];
	[btnSourceISO setEnabled:TRUE];
	if ([[txtDestinationFolder stringValue] length] == 0) [btnDestinationFolder setEnabled:FALSE];
}

- (IBAction)DisableISOSelecting:(id)sender
{
	[txtSourceISO setEnabled:FALSE];
	[btnSourceISO setEnabled:FALSE];
	[btnDestinationFolder setEnabled:TRUE];
}

- (IBAction)DoTheConversion:(id)sender
{
	const char* inputPath;
	int taskStatus = -1;
	NSFileManager* filemanager = [NSFileManager defaultManager];
	NSString* bsdpath;
	NSString* argbsdpath;
	NSString* outputPath;
	NSString* tempdir = NSTemporaryDirectory();
	NSString* isopath = [tempdir stringByAppendingFormat:@"cdimg.iso"];
	NSString* argisopath = [[NSString string] stringByAppendingFormat:@"of=%@",isopath];
	NSAlert* alertError = [NSAlert alertWithMessageText:@"No CD was found." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"No PSX CD found into your DVDROM. Please insert one..."];
	NSAlert* alertComplete = [NSAlert alertWithMessageText:@"Convertion completed!" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Your PSX game has been correctly converted, you can put it straight into your PSP. Enjoy!"];
	NSAlert* unknowError = [NSAlert alertWithMessageText:@"Your DVD Drive seems busy." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"It seems that another application is using it. Try closing it, and retry with iPoPS."];

	if ([optDVDROM state] == NSOnState)
	{
		if (![devDVDROMFound mediaIsPresent])
		{
			[alertError beginSheetModalForWindow:[NSApp mainWindow] modalDelegate:self didEndSelector:nil contextInfo:nil];
			return;
		}

		bsdpath = [self volumeNameWithBSDPath:[NSString stringWithFormat:@"/dev/%@",[devDVDROMFound bsdName]]];
		argbsdpath = [NSString stringWithFormat:@"if=/dev/%@",[devDVDROMFound bsdName]];
		outputPath = [NSString stringWithFormat:@"%@/%@/",[txtDestinationFolder stringValue],bsdpath];
	}
	else
	{
		outputPath = [NSString stringWithFormat:@"%@/%@/",[txtDestinationFolder stringValue],[[[txtSourceISO stringValue] lastPathComponent] stringByDeletingPathExtension]];
	}

	[stsStatusBar setUsesThreadedAnimation:TRUE];

	if ([optDVDROM state] == NSOnState)
	{
		NSTask* task;

		NSArray* ISOarguments;
		ISOarguments = [NSArray arrayWithObjects:argbsdpath, argisopath, @"bs=2048", @"conv=sync,notrunc", nil];

		NSArray* UnMountarguments;
		UnMountarguments = [NSArray arrayWithObjects:@"unmount", [NSString stringWithFormat:@"/dev/%@",[devDVDROMFound bsdName]], nil];

		NSArray* Mountarguments;
		Mountarguments = [NSArray arrayWithObjects:@"mount", [NSString stringWithFormat:@"/dev/%@",[devDVDROMFound bsdName]], nil];

		[self updateStatus:@"Making the ISO of your CD..."];

		// Unmount the disk
		task = [[NSTask alloc] init];
		[task setLaunchPath:@"/usr/bin/hdiutil"];
		[task setArguments:UnMountarguments];
		[task launch];
		[task waitUntilExit];
		// Get the ISO
		task = [[NSTask alloc] init];
		[task setLaunchPath:@"/bin/dd"];
		[task setArguments:ISOarguments];
		[task launch];
		[task waitUntilExit];
		taskStatus = [task terminationStatus];
		// Mount the disk
		task = [[NSTask alloc] init];
		[task setLaunchPath:@"/usr/bin/hdiutil"];
		[task setArguments:Mountarguments];
		[task launch];
		[task waitUntilExit];

		inputPath = [isopath UTF8String];
	}
	else
	{
		taskStatus = 0;
		inputPath = [[txtSourceISO stringValue] UTF8String];
	}

	if (taskStatus == 0)
	{
		if ([[txtIconFile stringValue] length] != 0) [self ResizeImage:[txtIconFile stringValue]:80.0:80.0];
		if ([[txtBackgroundFile stringValue] length] != 0) [self ResizeImage:[txtBackgroundFile stringValue]:480.0:272.0];

		[filemanager createDirectoryAtPath:outputPath withIntermediateDirectories:NO attributes:nil error:nil];
		[self convertToEBOOT:inputPath:[[NSString stringWithFormat:@"%@EBOOT.PBP",outputPath] UTF8String]:[txtCompressionLevel intValue]];
		[filemanager removeItemAtPath:isopath error:NULL];
		[filemanager copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"KEYS" ofType:@"BIN"] toPath:[NSString stringWithFormat:@"%@KEYS.BIN",outputPath] error:nil];
		if ([optDVDROM state] == NSOnState) [devDVDROMFound ejectMedia];
		[alertComplete beginSheetModalForWindow:[NSApp mainWindow] modalDelegate:self didEndSelector:nil contextInfo:nil];
	}
	else
	{
		[self updateStatus:@"An image of your CD could not be made.":14.0];
		[unknowError beginSheetModalForWindow:[NSApp mainWindow] modalDelegate:self didEndSelector:nil contextInfo:nil];
		[devDVDROMFound releaseExclusiveAccess];
	}

}

// Chiudo l'applicazione se chiudo anche la Form
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

- (void)updateStatus:(NSString*)str
{
	[self updateStatus:str:1.0];
}

- (void)updateStatus :(NSString*)str :(int)value
{
	// Effettuo i cambiamenti
	[lblStatusInfo setStringValue:[NSString stringWithFormat:@"Status: %@",str]];
	[stsStatusBar incrementBy:value];

	// Visualizzo i cambiamenti
	[lblStatusInfo display];
	[stsStatusBar display];
}

- (int)getSize:(FILE*)f
{
	int size;

	fseek(f, 0, SEEK_END);
	size = ftell(f);

	fseek(f, 0, SEEK_SET);
	return size;
}

- (int)deflateCompress :(void*)inbuf :(int)insize :(void*)outbuf :(int)outsize :(int)level
{
	int res;

	z.zalloc = Z_NULL;
	z.zfree  = Z_NULL;
	z.opaque = Z_NULL;

	if (deflateInit2(&z, level , Z_DEFLATED, -15, 8, Z_DEFAULT_STRATEGY) != Z_OK)
		return -1;

	z.next_out  = outbuf;
	z.avail_out = outsize;
	z.next_in   = inbuf;
	z.avail_in  = insize;

	if (deflate(&z, Z_FINISH) != Z_STREAM_END)
	{
		return -1;
	}

	res = outsize - z.avail_out;

	if (deflateEnd(&z) != Z_OK)
		return -1;

	return res;
}

- (void)SetSFOTitle :(char*)sfo :(NSString*)title
{
	SFOHeader *header = (SFOHeader *)sfo;
	SFODir *entries = (SFODir *)(sfo+0x14);
	int i;

	for (i = 0; i < header->nitems; i++)
	{
		if (strcmp(sfo+header->fields_table_offs+entries[i].field_offs, "TITLE") == 0)
		{
			strncpy(sfo+header->values_table_offs+entries[i].val_offs, [title UTF8String], entries[i].size);

			if (strlen([title UTF8String])+1 > entries[i].size)
			{
				entries[i].length = entries[i].size;
			}
			else
			{
				entries[i].length = strlen([title UTF8String])+1;
			}
		}
	}
}

- (void)SetSFOCode :(char*)sfo :(NSString*)code
{
	SFOHeader *header = (SFOHeader *)sfo;
	SFODir *entries = (SFODir *)(sfo+0x14);
	int i;

	for (i = 0; i < header->nitems; i++)
	{
		if (strcmp(sfo+header->fields_table_offs+entries[i].field_offs, "DISC_ID") == 0)
		{
			strncpy( sfo+(header->values_table_offs)+(entries[i].val_offs), [code UTF8String], entries[i].size);

			if (strlen([code UTF8String])+1 > entries[i].size)
			{
				entries[i].length = entries[i].size;
			}
			else
			{
				entries[i].length = strlen([code UTF8String])+1;
			}
		}
	}
}

- (void)convertToEBOOT :(const char*)input :(const char*)output :(int)complevel
{
	FILE *in_file = nil, *out_file = nil, *base, *t = nil;
	char buffer[1*1048576];
	char buffer2[0x9300];
	int *ib = (int*)buffer;
	unsigned int psp_header[0x30/4];
	unsigned int base_header[0x28/4];
	unsigned int header[0x28/4];
	unsigned int dummy[6];
	int i = 0, offset = 0, isosize = 0, isorealsize = 0, x = 0;
	int index_offset = 0, p1_offset = 0, p2_offset = 0, end_offset = 0;
	int pic0 = 0, pic1 = 0, icon0 = 0, icon1 = 0, snd = 0, prx = 0, boot = 0;
	int sfo_size = 0, pic0_size = 0, pic1_size = 0, icon0_size = 0, icon1_size = 0, snd_size = 0, prx_size = 0, boot_size = 0;
	int curoffs = 0x28;
	IsoIndex *indexes;

	in_file = fopen (input, "rb");

	isosize = [self getSize: in_file];
	isorealsize = isosize;
	if ((isosize % 0x9300) != 0) isosize = isosize + (0x9300 - (isosize%0x9300));

	base = fopen([[[NSBundle mainBundle] pathForResource:@"BASE" ofType:@"PBP"] UTF8String], "rb");

	out_file = fopen(output, "wb");

	[self updateStatus: @"Writing header..."];

	fread(base_header, 1, 0x28, base);

	sfo_size = base_header[3] - base_header[2];

	t = fopen([[txtIconFile stringValue] UTF8String], "rb");
	if (t)
	{
		icon0_size = [self getSize: t];
		icon0 = 1;
		fclose(t);
	}
	else
		icon0_size = base_header[4] - base_header[3];

	t = fopen([[txtAnimatedIconFile stringValue] UTF8String], "rb");
	if (t)
	{
		icon1_size = [self getSize: t];
		icon1 = 1;
		fclose(t);
	}
	else
		icon1_size = 0;

	t = fopen("PIC0.PNG", "rb");
	if (t)
	{
		pic0_size = [self getSize: t];
		pic0 = 1;
		fclose(t);
	}
	else
		pic0_size = 0; //base_header[6] - base_header[5];

	t = fopen([[txtBackgroundFile stringValue] UTF8String], "rb");
	if (t)
	{
		pic1_size = [self getSize: t];
		pic1 = 1;
		fclose(t);
	}
	else
		pic1_size = 0; //base_header[7] - base_header[6];

	t = fopen([[txtSoundFile stringValue] UTF8String], "rb");
	if (t)
	{
		snd_size = [self getSize: t];
		snd = 1;
		fclose(t);
	}
	else
		snd = 0;

	t = fopen([[txtBootPicture stringValue] UTF8String], "rb");
	if (t)
	{
		boot_size = [self getSize: t];
		boot = 1;
		fclose(t);
	}
	else
		boot = 0;

	t = fopen([[[NSBundle mainBundle] pathForResource:@"DATA" ofType:@"PSP"] UTF8String], "rb");
	if (t)
	{
		prx_size = [self getSize: t];
		prx = 1;
		fclose(t);
	}
	else
	{
		fseek(base, base_header[8], SEEK_SET);
		fread(psp_header, 1, 0x30, base);

		prx_size = psp_header[0x2C/4];
	}

	header[0] = 0x50425000;
	header[1] = 0x10000;

	header[2] = curoffs;

	curoffs += sfo_size;
	header[3] = curoffs;

	curoffs += icon0_size;
	header[4] = curoffs;

	curoffs += icon1_size;
	header[5] = curoffs;

	curoffs += pic0_size;
	header[6] = curoffs;

	curoffs += pic1_size;
	header[7] = curoffs;

	curoffs += snd_size;
	header[8] = curoffs;

	x = (header[8] + prx_size);

	if ((x % 0x10000) != 0)
	{
		x = x + (0x10000 - (x % 0x10000));
	}

	header[9] = x;

	fwrite(header, 1, 0x28, out_file);
	[self updateStatus: @"Writing sfo..."];
	fseek(base, base_header[2], SEEK_SET);
	fread(buffer, 1, sfo_size, base);
	[self SetSFOTitle:buffer:[txtGameTitle stringValue]];
	strcpy(buffer+0x108, [[txtGameID stringValue] UTF8String]);
	fwrite(buffer, 1, sfo_size, out_file);

	[self updateStatus: @"Writing icon0.png..."];
	if (!icon0)
	{
		fseek(base, base_header[3], SEEK_SET);
		fread(buffer, 1, icon0_size, base);
		fwrite(buffer, 1, icon0_size, out_file);
	}
	else
	{
		t = fopen([[txtIconFile stringValue] UTF8String], "rb");
		fread(buffer, 1, icon0_size, t);
		fwrite(buffer, 1, icon0_size, out_file);
		fclose(t);
	}

	[self updateStatus: @"Writing icon1.pmf..."];
	if (!icon1)
	{
		fseek(base, base_header[4], SEEK_SET);
		fread(buffer, 1, icon1_size, base);
		fwrite(buffer, 1, icon1_size, out_file);
	}
	else
	{
		t = fopen([[txtAnimatedIconFile stringValue] UTF8String], "rb");
		fread(buffer, 1, icon1_size, t);
		fwrite(buffer, 1, icon1_size, out_file);
		fclose(t);
	}

	[self updateStatus: @"Writing pic0.png..."];
	if (!pic0)

	{
		fseek(base, base_header[5], SEEK_SET);
		fread(buffer, 1, pic0_size, base);
		fwrite(buffer, 1, pic0_size, out_file);
	}
	else
	{
		t = fopen("PIC0.PNG", "rb");
		fread(buffer, 1, pic0_size, t);
		fwrite(buffer, 1, pic0_size, out_file);
		fclose(t);
	}

	[self updateStatus: @"Writing pic1.png..."];
	if (!pic1)
	{
		fseek(base, base_header[6], SEEK_SET);
		fread(buffer, 1, pic1_size, base);
		fwrite(buffer, 1, pic1_size, out_file);
	}
	else
	{
		t = fopen([[txtBackgroundFile stringValue] UTF8String], "rb");
		fread(buffer, 1, pic1_size, t);
		fwrite(buffer, 1, pic1_size, out_file);
		fclose(t);
	}

	[self updateStatus: @"Writing snd0.at3..."];
	if (!snd)
	{
		fseek(base, base_header[7], SEEK_SET);
		fread(buffer, 1, snd_size, base);
		fwrite(buffer, 1, snd_size, out_file);
	}
	else
	{
		t = fopen([[txtSoundFile stringValue] UTF8String], "rb");
		fread(buffer, 1, snd_size, t);
		fwrite(buffer, 1, snd_size, out_file);
		fclose(t);
	}

	[self updateStatus: @"Writing DATA.PSP..."];
	if (!prx)
	{
		fseek(base, base_header[8], SEEK_SET);
		fread(buffer, 1, prx_size, base);
		fwrite(buffer, 1, prx_size, out_file);
	}
	else
	{
		t = fopen([[[NSBundle mainBundle] pathForResource:@"DATA" ofType:@"PSP"] UTF8String], "rb");
		fread(buffer, 1, prx_size, t);
		fwrite(buffer, 1, prx_size, out_file);
		fclose(t);
	}

	offset = ftell(out_file);

	for (i = 0; i < header[9]-offset; i++)
		fputc(0, out_file);

	[self updateStatus: @"Writing iso header..."];
	fwrite("PSISOIMG0000", 1, 12, out_file);
	p1_offset = ftell(out_file);
	x = isosize + 0x100000;
	fwrite(&x, 1, 4, out_file);
	x = 0;

	for (i = 0; i < 0xFC; i++)
		fwrite(&x, 1, 4, out_file);

	memcpy(data1+1, [[txtGameID stringValue] UTF8String], 4);
	memcpy(data1+6, [[txtGameID stringValue] UTF8String]+4, 5);
	fwrite(data1, 1, sizeof(data1), out_file);

	p2_offset = ftell(out_file);
	x = isosize + 0x100000 + 0x2d31;
	fwrite(&x, 1, 4, out_file);

	strcpy((char*)(data2+8), [[txtGameTitle stringValue] UTF8String]);
	fwrite(data2, 1, sizeof(data2), out_file);

	index_offset = ftell(out_file);

	[self updateStatus: @"Writing indexes..."];

	memset(dummy, 0, sizeof(dummy));

	offset = 0;

	if (complevel == 0)
		x = 0x9300;
	else
		x = 0;

	for (i = 0; i < isosize / 0x9300; i++)
	{
		fwrite(&offset, 1, 4, out_file);
		fwrite(&x, 1, 4, out_file);
		fwrite(dummy, 1, sizeof(dummy), out_file);
		if (complevel == 0) offset += 0x9300;
	}

	offset = ftell(out_file);

	for (i = 0; i < (header[9]+0x100000)-offset; i++)
		fputc(0, out_file);

	[self updateStatus: @"Writing your disk game image..."];

	if (complevel == 0)
	{
		while ((x = fread(buffer, 1, 1048576, in_file)) > 0)
			fwrite(buffer, 1, x, out_file);

		for (i = 0; i < (isosize-isorealsize); i++)
			fputc(0, out_file);
	}
	else
	{
		indexes = (IsoIndex *)malloc(sizeof(IsoIndex) * (isosize/0x9300));

		if (!indexes)
		{
			fclose(in_file);
			fclose(out_file);
			fclose(base);

			//ErrorExit("Cannot alloc memory for indexes!\n");
		}

		i = 0;
		offset = 0;

		while ((x = fread(buffer2, 1, 0x9300, in_file)) > 0)
		{
			if (x < 0x9300)
			{
				memset(buffer2+x, 0, 0x9300-x);
			}

			x = [self deflateCompress:buffer2:0x9300:buffer:sizeof(buffer):complevel];

			if (x < 0)
			{
				fclose(in_file);
				fclose(out_file);
				fclose(base);
				free(indexes);

				//ErrorExit("Error in compression!\n");
			}

			memset(&indexes[i], 0, sizeof(IsoIndex));

			indexes[i].offset = offset;

			if (x >= 0x9300) /* Block didn't compress */
			{
				indexes[i].length = 0x9300;
				fwrite(buffer2, 1, 0x9300, out_file);
				offset += 0x9300;
			}
			else
			{
				indexes[i].length = x;
				fwrite(buffer, 1, x, out_file);
				offset += x;
			}

			i++;
		}

		if (i != (isosize/0x9300))
		{
			fclose(in_file);
			fclose(out_file);
			fclose(base);
			free(indexes);

			//ErrorExit("Some error happened.\n");
		}

		x = ftell(out_file);

		if ((x % 0x10) != 0)
		{
			end_offset = x + (0x10 - (x % 0x10));

			for (i = 0; i < (end_offset-x); i++)
			{
				fputc('0', out_file);
			}
		}
		else
		{
			end_offset = x;
		}

		end_offset -= header[9];
	}


	[self updateStatus: @"Writing special data..."];

	fseek(base, base_header[9]+12, SEEK_SET);
	fread(&x, 1, 4, base);

	x += 0x50000;

	fseek(base, x, SEEK_SET);
	fread(buffer, 1, 8, base);

	if (memcmp(buffer, "STARTDAT", 8) != 0)
	{
		/*ErrorExit("Cannot find STARTDAT in %s.\n",
			      "Not a valid PSX eboot.pbp\n", BASE);*/
	}
	fseek(base, x+16, SEEK_SET);
	fread(header, 1, 8, base);
	fseek(base, x, SEEK_SET);
	fread(buffer, 1, header[0], base);

	if (!boot)
	{
		fwrite(buffer, 1, header[0], out_file);
		fread(buffer, 1, header[1], base);
		fwrite(buffer, 1, header[1], out_file);
	}
	else
	{
		//printf("Writing boot.png...\n");

		ib[5] = boot_size;
		fwrite(buffer, 1, header[0], out_file);
		t = fopen([[txtBootPicture stringValue] UTF8String], "rb");
		fread(buffer, 1, boot_size, t);
		fwrite(buffer, 1, boot_size, out_file);
		fclose(t);
		fread(buffer, 1, header[1], base);
	}

	while ((x = fread(buffer, 1, 1048576, base)) > 0)
		fwrite(buffer, 1, x, out_file);

	if (complevel != 0)
	{
		[self updateStatus: @"Updating compressed indexes...\n"];

		fseek(out_file, p1_offset, SEEK_SET);
		fwrite(&end_offset, 1, 4, out_file);

		end_offset += 0x2d31;
		fseek(out_file, p2_offset, SEEK_SET);
		fwrite(&end_offset, 1, 4, out_file);

		fseek(out_file, index_offset, SEEK_SET);
		fwrite(indexes, 1, sizeof(IsoIndex) * (isosize/0x9300), out_file);
	}

	fclose(in_file);
	fclose(out_file);
	fclose(base);

	[self updateStatus: @"Finished!"];
}

// IMPORTED

- (NSString *) volumeNameWithBSDPath:(NSString *)bsdPath
{
    DASessionRef session;
    DADiskRef disk;
    NSDictionary *dd;
    NSString *volumeName;

    session = DASessionCreate(kCFAllocatorDefault);
    if (!session) {
        return nil;
    }

    disk = DADiskCreateFromBSDName(kCFAllocatorDefault, session, [bsdPath UTF8String]);
    if (!disk) {
        CFRelease(session);
        return nil;
    }

    dd = (NSDictionary *) DADiskCopyDescription(disk);
    if (!dd) {
        CFRelease(session);
        CFRelease(disk);
        return nil;
    }

    volumeName = [[dd objectForKey:(NSString *)kDADiskDescriptionVolumeNameKey] copy];

    CFRelease(session);
    CFRelease(disk);
    [dd release];

    return [volumeName autorelease];
}

- (void)ResizeImage :(NSString*)pathToFile :(CGFloat)width :(CGFloat)height
{
	NSImage* imgtoresize = [[[NSImage alloc] initWithContentsOfFile:pathToFile] autorelease];
	NSImage* resizedImage = [[[NSImage alloc] initWithSize:NSMakeSize(width, height)] autorelease];

	NSSize originalSize = [imgtoresize size];

	[resizedImage lockFocus];
	[imgtoresize drawInRect:NSMakeRect(0, 0, width, height) fromRect:NSMakeRect(0, 0, originalSize.width, originalSize.height) operation:NSCompositeSourceOver fraction:1.0];
	[resizedImage unlockFocus];
	NSData *data = [resizedImage TIFFRepresentation];
	[[[NSBitmapImageRep imageRepWithData:data] representationUsingType:NSPNGFileType properties:[[NSDictionary alloc] init]] writeToFile:pathToFile atomically:YES];
}

@end