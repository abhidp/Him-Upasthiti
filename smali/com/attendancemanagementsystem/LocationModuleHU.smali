.class public final Lcom/attendancemanagementsystem/LocationModuleHU;
.super Lcom/facebook/react/bridge/ReactContextBaseJavaModule;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/attendancemanagementsystem/LocationModuleHU$a;
    }
.end annotation


# static fields
.field public static final Companion:Lcom/attendancemanagementsystem/LocationModuleHU$a;

.field public static final REQUEST_CHECK_SETTINGS:I = 0x3e9


# instance fields
.field private final fusedLocationClient:Lcom/google/android/gms/location/FusedLocationProviderClient;

.field private final locationCallback:Lcom/attendancemanagementsystem/LocationModuleHU$b;

.field private final reactContext:Lcom/facebook/react/bridge/ReactApplicationContext;

.field private final settingsClient:Lcom/google/android/gms/location/SettingsClient;


# direct methods
.method static constructor <clinit>()V
    .locals 2

    new-instance v0, Lcom/attendancemanagementsystem/LocationModuleHU$a;

    const/4 v1, 0x0

    invoke-direct {v0, v1}, Lcom/attendancemanagementsystem/LocationModuleHU$a;-><init>(Lkotlin/jvm/internal/DefaultConstructorMarker;)V

    sput-object v0, Lcom/attendancemanagementsystem/LocationModuleHU;->Companion:Lcom/attendancemanagementsystem/LocationModuleHU$a;

    return-void
.end method

.method public constructor <init>(Lcom/facebook/react/bridge/ReactApplicationContext;)V
    .locals 2

    .line 1
    const-string v0, "reactContext"

    .line 2
    .line 3
    invoke-static {p1, v0}, Lh4/k;->f(Ljava/lang/Object;Ljava/lang/String;)V

    .line 4
    .line 5
    .line 6
    invoke-direct {p0, p1}, Lcom/facebook/react/bridge/ReactContextBaseJavaModule;-><init>(Lcom/facebook/react/bridge/ReactApplicationContext;)V

    .line 7
    .line 8
    .line 9
    iput-object p1, p0, Lcom/attendancemanagementsystem/LocationModuleHU;->reactContext:Lcom/facebook/react/bridge/ReactApplicationContext;

    .line 10
    .line 11
    invoke-static {p1}, Lcom/google/android/gms/location/LocationServices;->getFusedLocationProviderClient(Landroid/content/Context;)Lcom/google/android/gms/location/FusedLocationProviderClient;

    .line 12
    .line 13
    .line 14
    move-result-object v0

    .line 15
    const-string v1, "getFusedLocationProviderClient(...)"

    .line 16
    .line 17
    invoke-static {v0, v1}, Lh4/k;->e(Ljava/lang/Object;Ljava/lang/String;)V

    .line 18
    .line 19
    .line 20
    iput-object v0, p0, Lcom/attendancemanagementsystem/LocationModuleHU;->fusedLocationClient:Lcom/google/android/gms/location/FusedLocationProviderClient;

    .line 21
    .line 22
    invoke-static {p1}, Lcom/google/android/gms/location/LocationServices;->getSettingsClient(Landroid/content/Context;)Lcom/google/android/gms/location/SettingsClient;

    .line 23
    .line 24
    .line 25
    move-result-object p1

    .line 26
    const-string v0, "getSettingsClient(...)"

    .line 27
    .line 28
    invoke-static {p1, v0}, Lh4/k;->e(Ljava/lang/Object;Ljava/lang/String;)V

    .line 29
    .line 30
    .line 31
    iput-object p1, p0, Lcom/attendancemanagementsystem/LocationModuleHU;->settingsClient:Lcom/google/android/gms/location/SettingsClient;

    .line 32
    .line 33
    new-instance p1, Lcom/attendancemanagementsystem/LocationModuleHU$b;

    .line 34
    .line 35
    invoke-direct {p1, p0}, Lcom/attendancemanagementsystem/LocationModuleHU$b;-><init>(Lcom/attendancemanagementsystem/LocationModuleHU;)V

    .line 36
    .line 37
    .line 38
    iput-object p1, p0, Lcom/attendancemanagementsystem/LocationModuleHU;->locationCallback:Lcom/attendancemanagementsystem/LocationModuleHU$b;

    .line 39
    .line 40
    return-void
.end method

.method public static synthetic a(Lkotlin/jvm/functions/Function1;Ljava/lang/Object;)V
    .locals 0

    .line 1
    invoke-static {p0, p1}, Lcom/attendancemanagementsystem/LocationModuleHU;->checkAndRequestLocationEnabled$lambda$3(Lkotlin/jvm/functions/Function1;Ljava/lang/Object;)V

    return-void
.end method

.method public static final synthetic access$sendLocationEvent(Lcom/attendancemanagementsystem/LocationModuleHU;Landroid/location/Location;)V
    .locals 0

    .line 1
    invoke-direct {p0, p1}, Lcom/attendancemanagementsystem/LocationModuleHU;->sendLocationEvent(Landroid/location/Location;)V

    .line 2
    .line 3
    .line 4
    return-void
.end method

.method public static synthetic b(Lcom/attendancemanagementsystem/LocationModuleHU;Lcom/facebook/react/bridge/Promise;Ljava/lang/Exception;)V
    .locals 0

    .line 1
    invoke-static {p0, p1, p2}, Lcom/attendancemanagementsystem/LocationModuleHU;->checkAndRequestLocationEnabled$lambda$7(Lcom/attendancemanagementsystem/LocationModuleHU;Lcom/facebook/react/bridge/Promise;Ljava/lang/Exception;)V

    return-void
.end method

.method public static synthetic c(Lkotlin/jvm/functions/Function1;Ljava/lang/Object;)V
    .locals 0

    .line 1
    invoke-static {p0, p1}, Lcom/attendancemanagementsystem/LocationModuleHU;->startTracking$lambda$12$lambda$10(Lkotlin/jvm/functions/Function1;Ljava/lang/Object;)V

    return-void
.end method

.method private static final checkAndRequestLocationEnabled$lambda$2(Lcom/facebook/react/bridge/Promise;Lcom/google/android/gms/location/LocationSettingsResponse;)LS3/s;
    .locals 0

    .line 1
    sget-object p1, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    .line 2
    .line 3
    invoke-interface {p0, p1}, Lcom/facebook/react/bridge/Promise;->resolve(Ljava/lang/Object;)V

    .line 4
    .line 5
    .line 6
    sget-object p0, LS3/s;->a:LS3/s;

    .line 7
    .line 8
    return-object p0
.end method

.method private static final checkAndRequestLocationEnabled$lambda$3(Lkotlin/jvm/functions/Function1;Ljava/lang/Object;)V
    .locals 0

    .line 1
    invoke-interface {p0, p1}, Lkotlin/jvm/functions/Function1;->h(Ljava/lang/Object;)Ljava/lang/Object;

    .line 2
    .line 3
    .line 4
    return-void
.end method

.method private static final checkAndRequestLocationEnabled$lambda$7(Lcom/attendancemanagementsystem/LocationModuleHU;Lcom/facebook/react/bridge/Promise;Ljava/lang/Exception;)V
    .locals 3

    .line 1
    const-string v0, "exception"

    .line 2
    .line 3
    invoke-static {p2, v0}, Lh4/k;->f(Ljava/lang/Object;Ljava/lang/String;)V

    .line 4
    .line 5
    .line 6
    instance-of v0, p2, Lcom/google/android/gms/common/api/b;

    .line 7
    .line 8
    const/4 v1, 0x0

    .line 9
    if-eqz v0, :cond_0

    .line 10
    .line 11
    move-object v0, p2

    .line 12
    check-cast v0, Lcom/google/android/gms/common/api/b;

    .line 13
    .line 14
    goto :goto_0

    .line 15
    :cond_0
    move-object v0, v1

    .line 16
    :goto_0
    if-nez v0, :cond_1

    .line 17
    .line 18
    const-string p0, "UNKNOWN_ERROR"

    .line 19
    .line 20
    const-string v0, "Location settings check failed"

    .line 21
    .line 22
    invoke-interface {p1, p0, v0, p2}, Lcom/facebook/react/bridge/Promise;->reject(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)V

    .line 23
    .line 24
    .line 25
    return-void

    .line 26
    :cond_1
    invoke-virtual {v0}, Lcom/google/android/gms/common/api/b;->b()I

    .line 27
    .line 28
    .line 29
    move-result p2

    .line 30
    const/4 v2, 0x6

    .line 31
    if-eq p2, v2, :cond_3

    .line 32
    .line 33
    const/16 p0, 0x2136

    .line 34
    .line 35
    if-eq p2, p0, :cond_2

    .line 36
    .line 37
    invoke-virtual {v0}, Lcom/google/android/gms/common/api/b;->b()I

    .line 38
    .line 39
    .line 40
    move-result p0

    .line 41
    new-instance p2, Ljava/lang/StringBuilder;

    .line 42
    .line 43
    invoke-direct {p2}, Ljava/lang/StringBuilder;-><init>()V

    .line 44
    .line 45
    .line 46
    const-string v0, "Location settings error: "

    .line 47
    .line 48
    invoke-virtual {p2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 49
    .line 50
    .line 51
    invoke-virtual {p2, p0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    .line 52
    .line 53
    .line 54
    invoke-virtual {p2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    .line 55
    .line 56
    .line 57
    move-result-object p0

    .line 58
    const-string p2, "ERROR"

    .line 59
    .line 60
    invoke-interface {p1, p2, p0}, Lcom/facebook/react/bridge/Promise;->reject(Ljava/lang/String;Ljava/lang/String;)V

    .line 61
    .line 62
    .line 63
    return-void

    .line 64
    :cond_2
    const-string p0, "UNAVAILABLE"

    .line 65
    .line 66
    const-string p2, "Location settings cannot be changed"

    .line 67
    .line 68
    invoke-interface {p1, p0, p2}, Lcom/facebook/react/bridge/Promise;->reject(Ljava/lang/String;Ljava/lang/String;)V

    .line 69
    .line 70
    .line 71
    return-void

    .line 72
    :cond_3
    instance-of p2, v0, Lcom/google/android/gms/common/api/g;

    .line 73
    .line 74
    if-eqz p2, :cond_4

    .line 75
    .line 76
    move-object v1, v0

    .line 77
    check-cast v1, Lcom/google/android/gms/common/api/g;

    .line 78
    .line 79
    :cond_4
    if-eqz v1, :cond_6

    .line 80
    .line 81
    :try_start_0
    invoke-virtual {p0}, Lcom/facebook/react/bridge/ReactContextBaseJavaModule;->getCurrentActivity()Landroid/app/Activity;

    .line 82
    .line 83
    .line 84
    move-result-object p0

    .line 85
    if-nez p0, :cond_5

    .line 86
    .line 87
    const-string p0, "NO_ACTIVITY"

    .line 88
    .line 89
    const-string p2, "No current activity"

    .line 90
    .line 91
    invoke-interface {p1, p0, p2}, Lcom/facebook/react/bridge/Promise;->reject(Ljava/lang/String;Ljava/lang/String;)V

    .line 92
    .line 93
    .line 94
    return-void

    .line 95
    :catch_0
    move-exception p0

    .line 96
    goto :goto_1

    .line 97
    :cond_5
    const/16 p2, 0x3e9

    .line 98
    .line 99
    invoke-virtual {v1, p0, p2}, Lcom/google/android/gms/common/api/g;->c(Landroid/app/Activity;I)V

    .line 100
    .line 101
    .line 102
    sget-object p0, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    .line 103
    .line 104
    invoke-interface {p1, p0}, Lcom/facebook/react/bridge/Promise;->resolve(Ljava/lang/Object;)V
    :try_end_0
    .catch Landroid/content/IntentSender$SendIntentException; {:try_start_0 .. :try_end_0} :catch_0

    .line 105
    .line 106
    .line 107
    goto :goto_2

    .line 108
    :goto_1
    const-string p2, "DIALOG_FAILED"

    .line 109
    .line 110
    const-string v0, "Failed to show dialog"

    .line 111
    .line 112
    invoke-interface {p1, p2, v0, p0}, Lcom/facebook/react/bridge/Promise;->reject(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)V

    .line 113
    .line 114
    .line 115
    :goto_2
    return-void

    .line 116
    :cond_6
    const-string p0, "NOT_RESOLVABLE"

    .line 117
    .line 118
    const-string p2, "Resolution required but not possible"

    .line 119
    .line 120
    invoke-interface {p1, p0, p2}, Lcom/facebook/react/bridge/Promise;->reject(Ljava/lang/String;Ljava/lang/String;)V

    .line 121
    .line 122
    .line 123
    return-void
.end method

.method public static synthetic d(Lcom/facebook/react/bridge/Promise;Lcom/google/android/gms/location/LocationSettingsResponse;)LS3/s;
    .locals 0

    .line 1
    invoke-static {p0, p1}, Lcom/attendancemanagementsystem/LocationModuleHU;->checkAndRequestLocationEnabled$lambda$2(Lcom/facebook/react/bridge/Promise;Lcom/google/android/gms/location/LocationSettingsResponse;)LS3/s;

    move-result-object p0

    return-object p0
.end method

.method public static synthetic e(Lkotlin/jvm/functions/Function1;Ljava/lang/Object;)V
    .locals 0

    .line 1
    invoke-static {p0, p1}, Lcom/attendancemanagementsystem/LocationModuleHU;->startTracking$lambda$13(Lkotlin/jvm/functions/Function1;Ljava/lang/Object;)V

    return-void
.end method

.method public static synthetic f(Lcom/attendancemanagementsystem/LocationModuleHU;Landroid/location/Location;)LS3/s;
    .locals 0

    .line 1
    invoke-static {p0, p1}, Lcom/attendancemanagementsystem/LocationModuleHU;->startTracking$lambda$12$lambda$9(Lcom/attendancemanagementsystem/LocationModuleHU;Landroid/location/Location;)LS3/s;

    move-result-object p0

    return-object p0
.end method

.method public static synthetic g(Lcom/attendancemanagementsystem/LocationModuleHU;Ljava/lang/Exception;)V
    .locals 0

    .line 1
    invoke-static {p0, p1}, Lcom/attendancemanagementsystem/LocationModuleHU;->startTracking$lambda$14(Lcom/attendancemanagementsystem/LocationModuleHU;Ljava/lang/Exception;)V

    return-void
.end method

.method public static synthetic h(Lcom/attendancemanagementsystem/LocationModuleHU;Lcom/google/android/gms/location/LocationSettingsResponse;)LS3/s;
    .locals 0

    .line 1
    invoke-static {p0, p1}, Lcom/attendancemanagementsystem/LocationModuleHU;->startTracking$lambda$12(Lcom/attendancemanagementsystem/LocationModuleHU;Lcom/google/android/gms/location/LocationSettingsResponse;)LS3/s;

    move-result-object p0

    return-object p0
.end method

.method public static synthetic i(Ljava/lang/Exception;)V
    .locals 0

    .line 1
    invoke-static {p0}, Lcom/attendancemanagementsystem/LocationModuleHU;->startTracking$lambda$12$lambda$11(Ljava/lang/Exception;)V

    return-void
.end method

.method private final sendErrorEvent(Ljava/lang/String;Ljava/lang/String;)V
    .locals 2

    .line 1
    invoke-static {}, Lcom/facebook/react/bridge/Arguments;->createMap()Lcom/facebook/react/bridge/WritableMap;

    .line 2
    .line 3
    .line 4
    move-result-object v0

    .line 5
    const-string v1, "code"

    .line 6
    .line 7
    invoke-interface {v0, v1, p1}, Lcom/facebook/react/bridge/WritableMap;->putString(Ljava/lang/String;Ljava/lang/String;)V

    .line 8
    .line 9
    .line 10
    const-string p1, "message"

    .line 11
    .line 12
    invoke-interface {v0, p1, p2}, Lcom/facebook/react/bridge/WritableMap;->putString(Ljava/lang/String;Ljava/lang/String;)V

    .line 13
    .line 14
    .line 15
    const-string p1, "apply(...)"

    .line 16
    .line 17
    invoke-static {v0, p1}, Lh4/k;->e(Ljava/lang/Object;Ljava/lang/String;)V

    .line 18
    .line 19
    .line 20
    iget-object p1, p0, Lcom/attendancemanagementsystem/LocationModuleHU;->reactContext:Lcom/facebook/react/bridge/ReactApplicationContext;

    .line 21
    .line 22
    const-class p2, Lcom/facebook/react/modules/core/DeviceEventManagerModule$RCTDeviceEventEmitter;

    .line 23
    .line 24
    invoke-virtual {p1, p2}, Lcom/facebook/react/bridge/ReactContext;->getJSModule(Ljava/lang/Class;)Lcom/facebook/react/bridge/JavaScriptModule;

    .line 25
    .line 26
    .line 27
    move-result-object p1

    .line 28
    check-cast p1, Lcom/facebook/react/modules/core/DeviceEventManagerModule$RCTDeviceEventEmitter;

    .line 29
    .line 30
    const-string p2, "onLocationError"

    .line 31
    .line 32
    invoke-interface {p1, p2, v0}, Lcom/facebook/react/modules/core/DeviceEventManagerModule$RCTDeviceEventEmitter;->emit(Ljava/lang/String;Ljava/lang/Object;)V

    .line 33
    .line 34
    .line 35
    return-void
.end method

.method private final sendLocationEvent(Landroid/location/Location;)V
    .locals 4

    .line 1
    invoke-static {}, Lcom/facebook/react/bridge/Arguments;->createMap()Lcom/facebook/react/bridge/WritableMap;

    .line 2
    .line 3
    .line 4
    move-result-object v0

    .line 5
    invoke-virtual {p1}, Landroid/location/Location;->getLatitude()D

    .line 6
    .line 7
    .line 8
    move-result-wide v1

    .line 9
    const-string v3, "latitude"

    .line 10
    .line 11
    invoke-interface {v0, v3, v1, v2}, Lcom/facebook/react/bridge/WritableMap;->putDouble(Ljava/lang/String;D)V

    .line 12
    .line 13
    .line 14
    const-string v1, "longitude"

    .line 15
    .line 16
    invoke-virtual {p1}, Landroid/location/Location;->getLongitude()D

    .line 17
    .line 18
    .line 19
    move-result-wide v2

    .line 20
    invoke-interface {v0, v1, v2, v3}, Lcom/facebook/react/bridge/WritableMap;->putDouble(Ljava/lang/String;D)V

    .line 21
    .line 22
    .line 23
    invoke-virtual {p1}, Landroid/location/Location;->getAccuracy()F

    .line 24
    .line 25
    .line 26
    move-result v1

    .line 27
    float-to-double v1, v1

    .line 28
    const-string v3, "accuracy"

    .line 29
    .line 30
    invoke-interface {v0, v3, v1, v2}, Lcom/facebook/react/bridge/WritableMap;->putDouble(Ljava/lang/String;D)V

    .line 31
    .line 32
    .line 33
    const-string v1, "altitude"

    .line 34
    .line 35
    invoke-virtual {p1}, Landroid/location/Location;->getAltitude()D

    .line 36
    .line 37
    .line 38
    move-result-wide v2

    .line 39
    invoke-interface {v0, v1, v2, v3}, Lcom/facebook/react/bridge/WritableMap;->putDouble(Ljava/lang/String;D)V

    .line 40
    .line 41
    .line 42
    invoke-virtual {p1}, Landroid/location/Location;->getSpeed()F

    .line 43
    .line 44
    .line 45
    move-result v1

    .line 46
    float-to-double v1, v1

    .line 47
    const-string v3, "speed"

    .line 48
    .line 49
    invoke-interface {v0, v3, v1, v2}, Lcom/facebook/react/bridge/WritableMap;->putDouble(Ljava/lang/String;D)V

    .line 50
    .line 51
    .line 52
    invoke-virtual {p1}, Landroid/location/Location;->getBearing()F

    .line 53
    .line 54
    .line 55
    move-result v1

    .line 56
    float-to-double v1, v1

    .line 57
    const-string v3, "bearing"

    .line 58
    .line 59
    invoke-interface {v0, v3, v1, v2}, Lcom/facebook/react/bridge/WritableMap;->putDouble(Ljava/lang/String;D)V

    .line 60
    .line 61
    .line 62
    invoke-virtual {p1}, Landroid/location/Location;->getTime()J

    .line 63
    .line 64
    .line 65
    move-result-wide v1

    .line 66
    long-to-double v1, v1

    .line 67
    const-string v3, "timestamp"

    .line 68
    .line 69
    invoke-interface {v0, v3, v1, v2}, Lcom/facebook/react/bridge/WritableMap;->putDouble(Ljava/lang/String;D)V

    .line 70
    .line 71
    .line 72
    invoke-virtual {p1}, Landroid/location/Location;->getProvider()Ljava/lang/String;

    .line 73
    .line 74
    .line 75
    move-result-object v1

    .line 76
    if-nez v1, :cond_0

    .line 77
    .line 78
    const-string v1, "unknown"

    .line 79
    .line 80
    :cond_0
    const-string v2, "provider"

    .line 81
    .line 82
    invoke-interface {v0, v2, v1}, Lcom/facebook/react/bridge/WritableMap;->putString(Ljava/lang/String;Ljava/lang/String;)V

    .line 83
    .line 84
    .line 85
    const-string v1, "isFromMockProvider"

    .line 86
    .line 87
    invoke-virtual {p1}, Landroid/location/Location;->isFromMockProvider()Z

    .line 88
    .line 89
    .line 90
    move-result v2

    const/4 v2, 0x0

    .line 91
    invoke-interface {v0, v1, v2}, Lcom/facebook/react/bridge/WritableMap;->putBoolean(Ljava/lang/String;Z)V

    .line 92
    .line 93
    .line 94
    const-string v1, "hasAccuracy"

    .line 95
    .line 96
    invoke-virtual {p1}, Landroid/location/Location;->hasAccuracy()Z

    .line 97
    .line 98
    .line 99
    move-result v2

    .line 100
    invoke-interface {v0, v1, v2}, Lcom/facebook/react/bridge/WritableMap;->putBoolean(Ljava/lang/String;Z)V

    .line 101
    .line 102
    .line 103
    const-string v1, "hasAltitude"

    .line 104
    .line 105
    invoke-virtual {p1}, Landroid/location/Location;->hasAltitude()Z

    .line 106
    .line 107
    .line 108
    move-result v2

    .line 109
    invoke-interface {v0, v1, v2}, Lcom/facebook/react/bridge/WritableMap;->putBoolean(Ljava/lang/String;Z)V

    .line 110
    .line 111
    .line 112
    const-string v1, "hasSpeed"

    .line 113
    .line 114
    invoke-virtual {p1}, Landroid/location/Location;->hasSpeed()Z

    .line 115
    .line 116
    .line 117
    move-result v2

    .line 118
    invoke-interface {v0, v1, v2}, Lcom/facebook/react/bridge/WritableMap;->putBoolean(Ljava/lang/String;Z)V

    .line 119
    .line 120
    .line 121
    const-string v1, "hasBearing"

    .line 122
    .line 123
    invoke-virtual {p1}, Landroid/location/Location;->hasBearing()Z

    .line 124
    .line 125
    .line 126
    move-result p1

    .line 127
    invoke-interface {v0, v1, p1}, Lcom/facebook/react/bridge/WritableMap;->putBoolean(Ljava/lang/String;Z)V

    .line 128
    .line 129
    .line 130
    const-string p1, "apply(...)"

    .line 131
    .line 132
    invoke-static {v0, p1}, Lh4/k;->e(Ljava/lang/Object;Ljava/lang/String;)V

    .line 133
    .line 134
    .line 135
    iget-object p1, p0, Lcom/attendancemanagementsystem/LocationModuleHU;->reactContext:Lcom/facebook/react/bridge/ReactApplicationContext;

    .line 136
    .line 137
    const-class v1, Lcom/facebook/react/modules/core/DeviceEventManagerModule$RCTDeviceEventEmitter;

    .line 138
    .line 139
    invoke-virtual {p1, v1}, Lcom/facebook/react/bridge/ReactContext;->getJSModule(Ljava/lang/Class;)Lcom/facebook/react/bridge/JavaScriptModule;

    .line 140
    .line 141
    .line 142
    move-result-object p1

    .line 143
    check-cast p1, Lcom/facebook/react/modules/core/DeviceEventManagerModule$RCTDeviceEventEmitter;

    .line 144
    .line 145
    const-string v1, "onLocationUpdate"

    .line 146
    .line 147
    invoke-interface {p1, v1, v0}, Lcom/facebook/react/modules/core/DeviceEventManagerModule$RCTDeviceEventEmitter;->emit(Ljava/lang/String;Ljava/lang/Object;)V

    .line 148
    .line 149
    .line 150
    return-void
.end method

.method private static final startTracking$lambda$12(Lcom/attendancemanagementsystem/LocationModuleHU;Lcom/google/android/gms/location/LocationSettingsResponse;)LS3/s;
    .locals 4

    .line 1
    new-instance p1, Lcom/google/android/gms/location/CurrentLocationRequest$Builder;

    .line 2
    .line 3
    invoke-direct {p1}, Lcom/google/android/gms/location/CurrentLocationRequest$Builder;-><init>()V

    .line 4
    .line 5
    .line 6
    const/16 v0, 0x64

    .line 7
    .line 8
    invoke-virtual {p1, v0}, Lcom/google/android/gms/location/CurrentLocationRequest$Builder;->setPriority(I)Lcom/google/android/gms/location/CurrentLocationRequest$Builder;

    .line 9
    .line 10
    .line 11
    move-result-object p1

    .line 12
    const-wide/16 v1, 0x0

    .line 13
    .line 14
    invoke-virtual {p1, v1, v2}, Lcom/google/android/gms/location/CurrentLocationRequest$Builder;->setMaxUpdateAgeMillis(J)Lcom/google/android/gms/location/CurrentLocationRequest$Builder;

    .line 15
    .line 16
    .line 17
    move-result-object p1

    .line 18
    const-wide/32 v1, 0xafc8

    .line 19
    .line 20
    .line 21
    invoke-virtual {p1, v1, v2}, Lcom/google/android/gms/location/CurrentLocationRequest$Builder;->setDurationMillis(J)Lcom/google/android/gms/location/CurrentLocationRequest$Builder;

    .line 22
    .line 23
    .line 24
    move-result-object p1

    .line 25
    invoke-virtual {p1}, Lcom/google/android/gms/location/CurrentLocationRequest$Builder;->build()Lcom/google/android/gms/location/CurrentLocationRequest;

    .line 26
    .line 27
    .line 28
    move-result-object p1

    .line 29
    const-string v1, "build(...)"

    .line 30
    .line 31
    invoke-static {p1, v1}, Lh4/k;->e(Ljava/lang/Object;Ljava/lang/String;)V

    .line 32
    .line 33
    .line 34
    iget-object v2, p0, Lcom/attendancemanagementsystem/LocationModuleHU;->fusedLocationClient:Lcom/google/android/gms/location/FusedLocationProviderClient;

    .line 35
    .line 36
    const/4 v3, 0x0

    .line 37
    invoke-interface {v2, p1, v3}, Lcom/google/android/gms/location/FusedLocationProviderClient;->getCurrentLocation(Lcom/google/android/gms/location/CurrentLocationRequest;LT2/a;)LT2/h;

    .line 38
    .line 39
    .line 40
    move-result-object p1

    .line 41
    new-instance v2, Lf0/j;

    .line 42
    .line 43
    invoke-direct {v2, p0}, Lf0/j;-><init>(Lcom/attendancemanagementsystem/LocationModuleHU;)V

    .line 44
    .line 45
    .line 46
    new-instance v3, Lf0/k;

    .line 47
    .line 48
    invoke-direct {v3, v2}, Lf0/k;-><init>(Lkotlin/jvm/functions/Function1;)V

    .line 49
    .line 50
    .line 51
    invoke-virtual {p1, v3}, LT2/h;->d(LT2/f;)LT2/h;

    .line 52
    .line 53
    .line 54
    move-result-object p1

    .line 55
    new-instance v2, Lf0/l;

    .line 56
    .line 57
    invoke-direct {v2}, Lf0/l;-><init>()V

    .line 58
    .line 59
    .line 60
    invoke-virtual {p1, v2}, LT2/h;->c(LT2/e;)LT2/h;

    .line 61
    .line 62
    .line 63
    new-instance p1, Lcom/google/android/gms/location/LocationRequest$Builder;

    .line 64
    .line 65
    const-wide/16 v2, 0x1388

    .line 66
    .line 67
    invoke-direct {p1, v0, v2, v3}, Lcom/google/android/gms/location/LocationRequest$Builder;-><init>(IJ)V

    .line 68
    .line 69
    .line 70
    const-wide/16 v2, 0x3e8

    .line 71
    .line 72
    invoke-virtual {p1, v2, v3}, Lcom/google/android/gms/location/LocationRequest$Builder;->setMinUpdateIntervalMillis(J)Lcom/google/android/gms/location/LocationRequest$Builder;

    .line 73
    .line 74
    .line 75
    move-result-object p1

    .line 76
    const/4 v0, 0x0

    .line 77
    invoke-virtual {p1, v0}, Lcom/google/android/gms/location/LocationRequest$Builder;->setMinUpdateDistanceMeters(F)Lcom/google/android/gms/location/LocationRequest$Builder;

    .line 78
    .line 79
    .line 80
    move-result-object p1

    .line 81
    const/4 v0, 0x1

    .line 82
    invoke-virtual {p1, v0}, Lcom/google/android/gms/location/LocationRequest$Builder;->setWaitForAccurateLocation(Z)Lcom/google/android/gms/location/LocationRequest$Builder;

    .line 83
    .line 84
    .line 85
    move-result-object p1

    .line 86
    invoke-virtual {p1}, Lcom/google/android/gms/location/LocationRequest$Builder;->build()Lcom/google/android/gms/location/LocationRequest;

    .line 87
    .line 88
    .line 89
    move-result-object p1

    .line 90
    invoke-static {p1, v1}, Lh4/k;->e(Ljava/lang/Object;Ljava/lang/String;)V

    .line 91
    .line 92
    .line 93
    iget-object v0, p0, Lcom/attendancemanagementsystem/LocationModuleHU;->fusedLocationClient:Lcom/google/android/gms/location/FusedLocationProviderClient;

    .line 94
    .line 95
    iget-object p0, p0, Lcom/attendancemanagementsystem/LocationModuleHU;->locationCallback:Lcom/attendancemanagementsystem/LocationModuleHU$b;

    .line 96
    .line 97
    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    .line 98
    .line 99
    .line 100
    move-result-object v1

    .line 101
    invoke-interface {v0, p1, p0, v1}, Lcom/google/android/gms/location/FusedLocationProviderClient;->requestLocationUpdates(Lcom/google/android/gms/location/LocationRequest;Lcom/google/android/gms/location/LocationCallback;Landroid/os/Looper;)LT2/h;

    .line 102
    .line 103
    .line 104
    sget-object p0, LS3/s;->a:LS3/s;

    .line 105
    .line 106
    return-object p0
.end method

.method private static final startTracking$lambda$12$lambda$10(Lkotlin/jvm/functions/Function1;Ljava/lang/Object;)V
    .locals 0

    .line 1
    invoke-interface {p0, p1}, Lkotlin/jvm/functions/Function1;->h(Ljava/lang/Object;)Ljava/lang/Object;

    .line 2
    .line 3
    .line 4
    return-void
.end method

.method private static final startTracking$lambda$12$lambda$11(Ljava/lang/Exception;)V
    .locals 1

    const-string v0, "it"

    invoke-static {p0, v0}, Lh4/k;->f(Ljava/lang/Object;Ljava/lang/String;)V

    return-void
.end method

.method private static final startTracking$lambda$12$lambda$9(Lcom/attendancemanagementsystem/LocationModuleHU;Landroid/location/Location;)LS3/s;
    .locals 0

    .line 1
    if-eqz p1, :cond_0

    .line 2
    .line 3
    invoke-direct {p0, p1}, Lcom/attendancemanagementsystem/LocationModuleHU;->sendLocationEvent(Landroid/location/Location;)V

    .line 4
    .line 5
    .line 6
    :cond_0
    sget-object p0, LS3/s;->a:LS3/s;

    .line 7
    .line 8
    return-object p0
.end method

.method private static final startTracking$lambda$13(Lkotlin/jvm/functions/Function1;Ljava/lang/Object;)V
    .locals 0

    .line 1
    invoke-interface {p0, p1}, Lkotlin/jvm/functions/Function1;->h(Ljava/lang/Object;)Ljava/lang/Object;

    .line 2
    .line 3
    .line 4
    return-void
.end method

.method private static final startTracking$lambda$14(Lcom/attendancemanagementsystem/LocationModuleHU;Ljava/lang/Exception;)V
    .locals 1

    .line 1
    const-string v0, "it"

    .line 2
    .line 3
    invoke-static {p1, v0}, Lh4/k;->f(Ljava/lang/Object;Ljava/lang/String;)V

    .line 4
    .line 5
    .line 6
    const-string p1, "LOCATION_DISABLED"

    .line 7
    .line 8
    const-string v0, "Location services are disabled or settings insufficient"

    .line 9
    .line 10
    invoke-direct {p0, p1, v0}, Lcom/attendancemanagementsystem/LocationModuleHU;->sendErrorEvent(Ljava/lang/String;Ljava/lang/String;)V

    .line 11
    .line 12
    .line 13
    return-void
.end method


# virtual methods
.method public final checkAndRequestLocationEnabled(Lcom/facebook/react/bridge/Promise;)V
    .locals 4
    .annotation runtime Lcom/facebook/react/bridge/ReactMethod;
    .end annotation

    .line 1
    const-string v0, "promise"

    .line 2
    .line 3
    invoke-static {p1, v0}, Lh4/k;->f(Ljava/lang/Object;Ljava/lang/String;)V

    .line 4
    .line 5
    .line 6
    new-instance v0, Lcom/google/android/gms/location/LocationRequest$Builder;

    .line 7
    .line 8
    const/16 v1, 0x64

    .line 9
    .line 10
    const-wide/16 v2, 0x3e8

    .line 11
    .line 12
    invoke-direct {v0, v1, v2, v3}, Lcom/google/android/gms/location/LocationRequest$Builder;-><init>(IJ)V

    .line 13
    .line 14
    .line 15
    const-wide/16 v1, 0x1f4

    .line 16
    .line 17
    invoke-virtual {v0, v1, v2}, Lcom/google/android/gms/location/LocationRequest$Builder;->setMinUpdateIntervalMillis(J)Lcom/google/android/gms/location/LocationRequest$Builder;

    .line 18
    .line 19
    .line 20
    move-result-object v0

    .line 21
    const/4 v1, 0x1

    .line 22
    invoke-virtual {v0, v1}, Lcom/google/android/gms/location/LocationRequest$Builder;->setWaitForAccurateLocation(Z)Lcom/google/android/gms/location/LocationRequest$Builder;

    .line 23
    .line 24
    .line 25
    move-result-object v0

    .line 26
    const/4 v2, 0x0

    .line 27
    invoke-virtual {v0, v2}, Lcom/google/android/gms/location/LocationRequest$Builder;->setGranularity(I)Lcom/google/android/gms/location/LocationRequest$Builder;

    .line 28
    .line 29
    .line 30
    move-result-object v0

    .line 31
    invoke-virtual {v0}, Lcom/google/android/gms/location/LocationRequest$Builder;->build()Lcom/google/android/gms/location/LocationRequest;

    .line 32
    .line 33
    .line 34
    move-result-object v0

    .line 35
    const-string v2, "build(...)"

    .line 36
    .line 37
    invoke-static {v0, v2}, Lh4/k;->e(Ljava/lang/Object;Ljava/lang/String;)V

    .line 38
    .line 39
    .line 40
    new-instance v3, Lcom/google/android/gms/location/LocationSettingsRequest$Builder;

    .line 41
    .line 42
    invoke-direct {v3}, Lcom/google/android/gms/location/LocationSettingsRequest$Builder;-><init>()V

    .line 43
    .line 44
    .line 45
    invoke-virtual {v3, v0}, Lcom/google/android/gms/location/LocationSettingsRequest$Builder;->addLocationRequest(Lcom/google/android/gms/location/LocationRequest;)Lcom/google/android/gms/location/LocationSettingsRequest$Builder;

    .line 46
    .line 47
    .line 48
    move-result-object v0

    .line 49
    invoke-virtual {v0, v1}, Lcom/google/android/gms/location/LocationSettingsRequest$Builder;->setAlwaysShow(Z)Lcom/google/android/gms/location/LocationSettingsRequest$Builder;

    .line 50
    .line 51
    .line 52
    move-result-object v0

    .line 53
    invoke-virtual {v0}, Lcom/google/android/gms/location/LocationSettingsRequest$Builder;->build()Lcom/google/android/gms/location/LocationSettingsRequest;

    .line 54
    .line 55
    .line 56
    move-result-object v0

    .line 57
    invoke-static {v0, v2}, Lh4/k;->e(Ljava/lang/Object;Ljava/lang/String;)V

    .line 58
    .line 59
    .line 60
    iget-object v1, p0, Lcom/attendancemanagementsystem/LocationModuleHU;->settingsClient:Lcom/google/android/gms/location/SettingsClient;

    .line 61
    .line 62
    invoke-interface {v1, v0}, Lcom/google/android/gms/location/SettingsClient;->checkLocationSettings(Lcom/google/android/gms/location/LocationSettingsRequest;)LT2/h;

    .line 63
    .line 64
    .line 65
    move-result-object v0

    .line 66
    new-instance v1, Lf0/g;

    .line 67
    .line 68
    invoke-direct {v1, p1}, Lf0/g;-><init>(Lcom/facebook/react/bridge/Promise;)V

    .line 69
    .line 70
    .line 71
    new-instance v2, Lf0/h;

    .line 72
    .line 73
    invoke-direct {v2, v1}, Lf0/h;-><init>(Lkotlin/jvm/functions/Function1;)V

    .line 74
    .line 75
    .line 76
    invoke-virtual {v0, v2}, LT2/h;->d(LT2/f;)LT2/h;

    .line 77
    .line 78
    .line 79
    move-result-object v0

    .line 80
    new-instance v1, Lf0/i;

    .line 81
    .line 82
    invoke-direct {v1, p0, p1}, Lf0/i;-><init>(Lcom/attendancemanagementsystem/LocationModuleHU;Lcom/facebook/react/bridge/Promise;)V

    .line 83
    .line 84
    .line 85
    invoke-virtual {v0, v1}, LT2/h;->c(LT2/e;)LT2/h;

    .line 86
    .line 87
    .line 88
    return-void
.end method

.method public getName()Ljava/lang/String;
    .locals 1

    .line 1
    const-string v0, "LocationModuleHU"

    .line 2
    .line 3
    return-object v0
.end method

.method public final startTracking()V
    .locals 4
    .annotation runtime Lcom/facebook/react/bridge/ReactMethod;
    .end annotation

    .line 1
    iget-object v0, p0, Lcom/attendancemanagementsystem/LocationModuleHU;->reactContext:Lcom/facebook/react/bridge/ReactApplicationContext;

    .line 2
    .line 3
    const-string v1, "android.permission.ACCESS_FINE_LOCATION"

    .line 4
    .line 5
    invoke-static {v0, v1}, Lv/a;->a(Landroid/content/Context;Ljava/lang/String;)I

    .line 6
    .line 7
    .line 8
    move-result v0

    .line 9
    if-eqz v0, :cond_0

    .line 10
    .line 11
    const-string v0, "PERMISSION_DENIED"

    .line 12
    .line 13
    const-string v1, "ACCESS_FINE_LOCATION not granted"

    .line 14
    .line 15
    invoke-direct {p0, v0, v1}, Lcom/attendancemanagementsystem/LocationModuleHU;->sendErrorEvent(Ljava/lang/String;Ljava/lang/String;)V

    .line 16
    .line 17
    .line 18
    return-void

    .line 19
    :cond_0
    new-instance v0, Lcom/google/android/gms/location/LocationRequest$Builder;

    .line 20
    .line 21
    const/16 v1, 0x64

    .line 22
    .line 23
    const-wide/16 v2, 0x3e8

    .line 24
    .line 25
    invoke-direct {v0, v1, v2, v3}, Lcom/google/android/gms/location/LocationRequest$Builder;-><init>(IJ)V

    .line 26
    .line 27
    .line 28
    invoke-virtual {v0}, Lcom/google/android/gms/location/LocationRequest$Builder;->build()Lcom/google/android/gms/location/LocationRequest;

    .line 29
    .line 30
    .line 31
    move-result-object v0

    .line 32
    const-string v1, "build(...)"

    .line 33
    .line 34
    invoke-static {v0, v1}, Lh4/k;->e(Ljava/lang/Object;Ljava/lang/String;)V

    .line 35
    .line 36
    .line 37
    new-instance v2, Lcom/google/android/gms/location/LocationSettingsRequest$Builder;

    .line 38
    .line 39
    invoke-direct {v2}, Lcom/google/android/gms/location/LocationSettingsRequest$Builder;-><init>()V

    .line 40
    .line 41
    .line 42
    invoke-virtual {v2, v0}, Lcom/google/android/gms/location/LocationSettingsRequest$Builder;->addLocationRequest(Lcom/google/android/gms/location/LocationRequest;)Lcom/google/android/gms/location/LocationSettingsRequest$Builder;

    .line 43
    .line 44
    .line 45
    move-result-object v0

    .line 46
    invoke-virtual {v0}, Lcom/google/android/gms/location/LocationSettingsRequest$Builder;->build()Lcom/google/android/gms/location/LocationSettingsRequest;

    .line 47
    .line 48
    .line 49
    move-result-object v0

    .line 50
    invoke-static {v0, v1}, Lh4/k;->e(Ljava/lang/Object;Ljava/lang/String;)V

    .line 51
    .line 52
    .line 53
    iget-object v1, p0, Lcom/attendancemanagementsystem/LocationModuleHU;->settingsClient:Lcom/google/android/gms/location/SettingsClient;

    .line 54
    .line 55
    invoke-interface {v1, v0}, Lcom/google/android/gms/location/SettingsClient;->checkLocationSettings(Lcom/google/android/gms/location/LocationSettingsRequest;)LT2/h;

    .line 56
    .line 57
    .line 58
    move-result-object v0

    .line 59
    new-instance v1, Lf0/d;

    .line 60
    .line 61
    invoke-direct {v1, p0}, Lf0/d;-><init>(Lcom/attendancemanagementsystem/LocationModuleHU;)V

    .line 62
    .line 63
    .line 64
    new-instance v2, Lf0/e;

    .line 65
    .line 66
    invoke-direct {v2, v1}, Lf0/e;-><init>(Lkotlin/jvm/functions/Function1;)V

    .line 67
    .line 68
    .line 69
    invoke-virtual {v0, v2}, LT2/h;->d(LT2/f;)LT2/h;

    .line 70
    .line 71
    .line 72
    move-result-object v0

    .line 73
    new-instance v1, Lf0/f;

    .line 74
    .line 75
    invoke-direct {v1, p0}, Lf0/f;-><init>(Lcom/attendancemanagementsystem/LocationModuleHU;)V

    .line 76
    .line 77
    .line 78
    invoke-virtual {v0, v1}, LT2/h;->c(LT2/e;)LT2/h;

    .line 79
    .line 80
    .line 81
    return-void
.end method

.method public final stopTracking()V
    .locals 2
    .annotation runtime Lcom/facebook/react/bridge/ReactMethod;
    .end annotation

    .line 1
    iget-object v0, p0, Lcom/attendancemanagementsystem/LocationModuleHU;->fusedLocationClient:Lcom/google/android/gms/location/FusedLocationProviderClient;

    .line 2
    .line 3
    iget-object v1, p0, Lcom/attendancemanagementsystem/LocationModuleHU;->locationCallback:Lcom/attendancemanagementsystem/LocationModuleHU$b;

    .line 4
    .line 5
    invoke-interface {v0, v1}, Lcom/google/android/gms/location/FusedLocationProviderClient;->removeLocationUpdates(Lcom/google/android/gms/location/LocationCallback;)LT2/h;

    .line 6
    .line 7
    .line 8
    return-void
.end method
